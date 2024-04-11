# SpryKit

SpryKit is a framework that allows spying and stubbing in Apple's Swift language.

__Table of Contents__

* [Motivation](#motivation)
* [Spryable](#spryable)
* [Stubbable](#stubbable)
* [Spyable](#spyable)
* [XCTAsserts](#xctasserts)
    * [XCTAssertHaveReceived / XCTAssertHaveNotReceived](#xctasserthavereceived--xctasserthavenotreceived)
    * [XCTAssertEqualAny / XCTAssertNotEqualAny](#xctassertequalany--xctassertnotequalany)
    * [XCTAssertThrowsAssertion](#xctassertthrowsassertion)
    * [XCTAssertThrowsError / XCTAssertNoThrowError](#xctassertthrowserror--xctassertnothrowerror)
    * [XCTAssertEqualError / XCTAssertNotEqualError](#xctassertequalerror--xctassertnotequalerror)
    * [XCTAssertEqualImage / XCTAssertNotEqualImage](#xctassertequalimage--xctassertnotequalimage)
* [SpryEquatable](#spryequatable)
* [Argument](#Argument)
* [ArgumentCaptor](#argumentcaptor)

## Motivation

When writing tests for a class, it is advised to only test that class's behavior and not the other objects it uses. With Swift this can be difficult.
How do you check if you are calling the correct methods at the appropriate times and passing in the appropriate arguments? SpryKit allows you to easily make a spy object that records every called function and the passed-in arguments.
How do you ensure that an injected object is going to return the necessary values for a given test? SpryKit allows you to easily make a stub object that can return a specific value.
This way you can write tests from the point of view of the class you are testing (the subject under test) and nothing more.

## Spryable

Conform to both Stubbable and Spyable at the same time! For information about [Stubbable](#stubbable) and [Spyable](#spyable) see their respective sections below.

__Abilities__

* Conform to `Spyable` and `Stubbable` at the same time.
* Reset calls and stubs at the same time with `resetCallsAndStubs()`
* Easy to implement
    * Create an object that conforms to `Spryable`
    * In every function (the ones that should be stubbed and spied) return the result of `spryify()` passing in all arguments (if any)
        * also works for special functions like `subscript`
    * In every property (the ones that should be stubbed and spied) return the result of `stubbedValue()` in the `get {}` and use `recordCall()` in the `set {}`

```swift
// The Real Thing can be a protocol
protocol StringService: class {
    var readonlyProperty: String { get }
    var readwriteProperty: String { set get }
    func doThings()
    func giveMeAString(arg1: Bool, arg2: String) -> String
    class func giveMeAString(arg1: Bool, arg2: String) -> String
}

// The Real Thing can be a class
class StringService {
    var readonlyProperty: String {
        return ""
    }

    var readwriteProperty: String = ""

    func doThings() {
        // do real things
    }

    func giveMeAString(arg1: Bool, arg2: String) -> String {
        // do real things
        return ""
    }

    class func giveMeAString(arg1: Bool, arg2: String) -> String {
        // do real things
        return ""
    }
}

// The Fake Class (If the fake is from a class then `override` will be required for each function and property)
class FakeStringService: StringService, Spryable {
    enum ClassFunction: String, StringRepresentable { // <-- **REQUIRED**
        case giveMeAString = "giveMeAString(arg1:arg2:)"
    }

    enum Function: String, StringRepresentable { // <-- **REQUIRED**
        case readonlyProperty = "readonlyProperty"
        case readwriteProperty = "readwriteProperty"
        case doThings = "doThings()"
        case giveMeAString = "giveMeAString(arg1:arg2:)"
    }

    var readonlyProperty: String {
        return stubbedValue()
    }

    var readwriteProperty: String {
        set {
            recordCall(arguments: newValue)
        }
        get {
            return stubbedValue()
        }
    }

    func doThings() {
        return spryify() // <-- **REQUIRED**
    }

    func giveMeAString(arg1: Bool, arg2: String) -> String {
        return spryify(arguments: arg1, arg2) // <-- **REQUIRED**
    }

    class func giveMeAString(arg1: Bool, arg2: String) -> String {
        return spryify(arguments: arg1, arg2) // <-- **REQUIRED**
    }
}
```

## Stubbable

_Spryable conforms to Stubbable.

__Abilities__

* Stub a return value for a function on an instance of a class or the class itself using `.andReturn()`
* Stub the implementation for a function on an instance of a class or the class itself using `.andDo()`
    * `.andDo()` takes in a closure that passes in an `Array` containing the parameters and should return the stubbed value
* Specify stubs that only get used if the right arguments are passed in using `.with()` (see [Argument Enum](#argument-enum) for alternate specifications)
* Rich `fatalError()` messages that include a detailed list of all stubbed functions when no stub is found (or the arguments received didn't pass validation)
* Reset stubs with `resetStubs()`

```swift
// will always return `"stubbed value"`
fakeStringService.stub(.hereAreTwoStrings).andReturn("stubbed value")

// defaults to return Void()
fakeStringService.stub(.hereAreTwoStrings).andReturn()

// specifying all arguments (will only return `true` if the arguments passed in match "first string" and "second string")
fakeStringService.stub(.hereAreTwoStrings).with("first string", "second string").andReturn(true)

// using the Arguement enum (will only return `true` if the second argument is "only this string matters")
fakeStringService.stub(.hereAreTwoStrings).with(Argument.anything, "only this string matters").andReturn(true)

// using custom validation
let customArgumentValidation = Argument.pass({ actualArgument -> Bool in
    let passesCustomValidation = // ...
    return passesCustomValidation
})
fakeStringService.stub(.hereAreTwoStrings).with(Argument.anything, customArgumentValidation).andReturn("stubbed value")

// using argument captor
let captor = Argument.captor()
fakeStringService.stub(.hereAreTwoStrings).with(Argument.nonNil, captor).andReturn("stubbed value")
captor.getValue(as: String.self) // gets the second argument the first time this function was called where the first argument was also non-nil.
captor.getValue(at: 1, as: String.self) // // gets the second argument the second time this function was called where the first argument was also non-nil.

// using `andDo()` - Also has the ability to specify the arguments!
fakeStringService.stub(.iHaveACompletionClosure).with("correct string", Argument.anything).andDo({ arguments in
    // get the passed in argument
    let completionClosure = arguments[0] as! () -> Void

    // use the argument
    completionClosure()

    // return an appropriate value
    return Void() // <-- will be returned by the stub
})

// can stub class functions as well
FakeStringService.stub(.imAClassFunction).andReturn(Void())

// do not forget to reset class stubs (since Class objects are essentially singletons)
FakeStringService.resetStubs()
```

## Spyable

_Spryable conforms to Spyable.

__Abilities__

* Test whether a function was called or a property was set on an instance of a class or the class itself
* Specify the arguments that should have been received along with the call (see [Argument Enum](#argument-enum) for alternate specifications)
* Rich Failure messages that include a detailed list of called functions and arguments
* Reset calls with `resetCalls()`

__The Result__

```swift
// the result
let result = spyable.didCall(.functionName)

// was the function called on the fake?
result.success

// what was called on the fake?
result.recordedCallsDescription
```

__How to Use__

```swift
// passes if the function was called
fake.didCall(.functionName).success

// passes if the function was called a number of times
fake.didCall(.functionName, countSpecifier: .exactly(1)).success

// passes if the function was called at least a number of times
fake.didCall(.functionName, countSpecifier: .atLeast(1)).success

// passes if the function was called at most a number of times
fake.didCall(.functionName, countSpecifier: .atMost(1)).success

// passes if the function was called with equivalent arguments
fake.didCall(.functionName, withArguments: ["firstArg", "secondArg"]).success

// passes if the function was called with arguments that pass the specified options
fake.didCall(.functionName, withArguments: [Argument.nonNil, Argument.anything, "thirdArg"]).success

// passes if the function was called with an argument that passes the custom validation
let customArgumentValidation = Argument.pass({ argument -> Bool in
    let passesCustomValidation = // ...
    return passesCustomValidation
})
fake.didCall(.functionName, withArguments: [customArgumentValidation]).success

// passes if the function was called with equivalent arguments a number of times
fake.didCall(.functionName, withArguments: ["firstArg", "secondArg"], countSpecifier: .exactly(1)).success

// passes if the property was set to the right value
fake.didCall(.propertyName, with: "value").success

// passes if the class function was called
Fake.didCall(.functionName).success
```

## XCTAsserts

SpryKit provides a set of `XCTAssert` functions to make testing with SpryKit easier.

### XCTAssertHaveReceived / XCTAssertHaveNotReceived

Have Received Matcher is made to be used with XCTest.

```swift
// passes if the function was called
XCTAssertHaveReceived(fake, .functionName)

// passes if the function was called a number of times
XCTAssertHaveReceived(fake, .functionName, countSpecifier: .exactly(1))

// passes if the function was called at least a number of times
XCTAssertHaveReceived(fake, .functionName, countSpecifier: .atLeast(2))

// passes if the function was called at most a number of times
XCTAssertHaveReceived(fake, .functionName, countSpecifier: .atMost(1))

// passes if the function was called with equivalent arguments
XCTAssertHaveReceived(fake, .functionName, with: "firstArg", "secondArg")

// passes if the function was called with arguments that pass the specified options
XCTAssertHaveReceived(fake, .functionName, with: Argument.nonNil, Argument.anything, "thirdArg")

// passes if the function was called with an argument that passes the custom validation
let customArgumentValidation = Argument.validator({ argument -> Bool in
    let passesCustomValidation = // ...
    return passesCustomValidation
})
XCTAssertHaveReceived(fake, .functionName, with: customArgumentValidation)

// passes if the function was called with equivalent arguments a number of times
XCTAssertHaveReceived(fake, .functionName, with: "firstArg", "secondArg", countSpecifier: .exactly(1))

// passes if the property was set to the specified value
XCTAssertHaveReceived(fake, .propertyName, with: "value")

// passes if the class function was called
XCTAssertHaveReceived(Fake.self, .functionName)

// passes if the class property was set
XCTAssertHaveReceived(Fake.self, .propertyName)

// do not forget to reset calls on class objects (since Class objects are essentially singletons)
Fake.resetCallsAndStubs()
```

### XCTAssertEqualAny / XCTAssertNotEqualAny

Function that compares two values of any type. This is useful when you need to compare two instances of a class/struct `#FF0000` **`even if they are not conform to `Equatable` protocol`** `#000000`.

```swift
struct User {
    let name: String
    let age: Int
}
XCTAssertEqualAny(User(name: "John", age: 30), User(name: "John", age: 30))
XCTAssertNotEqualAny(User(name: "Bob", age: 20), User(name: "John", age: 30))
```

### XCTAssertThrowsAssertion

Function that checks if the block throws an assertion.

```swift
XCTAssertThrowsAssertion {
    assertionFailure("should catch this assertion failure")
}
```

### XCTAssertThrowsError / XCTAssertNoThrowError

Function that checks if the block throws an error.

```swift
private func throwError() throws {
    throw XCTAssertThrowsErrorTests.Error.one
}

XCTAssertThrowsError(Error.one) {
    try throwError()
}

private func notThrowError() throws {
    // nothig
}
XCTAssertNoThrowError(try notThrowError())
```

### XCTAssertEqualError / XCTAssertNotEqualError

Function that compares two errors.
```swift
XCTAssertEqualError(Error.one, Error.one)
XCTAssertNotEqualError(Error.one, Error.two)
```

### XCTAssertEqualImage / XCTAssertNotEqualImage

Function that compares two images by their data representation even if they are not the same type.
> [!TIP]
> Use mocked images by `UIImage.spry.testImage`

```swift
XCTAssertEqualImage(Image.spry.testImage, Image.spry.testImage)
XCTAssertNotEqualImage(Image.spry.testImage, Image.spry.testImage2)
```

## SpryEquatable

SpryKit uses the SpryEquatable protocol to override comparisons in your test classes on your own risk. This is useful when you need to compare two instances of a class/struct that is not conform to `Equatable` and/or you need to skip some properties in the comparison (ex. closures). 
Make types conform to `SpryEquatable` only when you neeed something very specific, otherwise use `Equatable` protocol or `XCTAssertEqualAny`. 

```swift
// custom type
extension Person: SpryEquatable {
    public state func == (lhs: Person, rhs: Person) -> Bool {
        return lhs.name == rhs.name
            && lhs.age == rhs.age
    }
}
```

## Argument

Use when the exact comparison of an argument using the `Equatable` protocol is not desired, needed, or possible.

* `case anything`
    * Used to indicate that absolutely anything passed in will be sufficient.
* `case nonNil`
    * Used to indicate that anything non-nil passed in will be sufficient.
* `case nil`
    * Used to indicate that only nil passed in will be sufficient.
* `case validator`
    * Used to provide custom validation for a specific argument.
    * The associated value is a closure which takes in the argument and returns a bool to indicate whether or not it passed validation.
* `func captor`
    * Used to create a new [ArgumentCaptor](#argumentcaptor)
    * An argument captor is used to capture arguments as the function is called so that they can be accessed at a later point.
* `func isType<T>`
    * Type is exactly the type passed in match this qualification (subtypes do NOT qualify).
* `func instanceOf<T>`
    * Only objects whose type is exactly the type passed in match this qualification (subtypes do NOT qualify).

## ArgumentCaptor

ArgumentCaptor is used to capture a specific argument when the stubbed function is called. Afterward the captor can serve up the captured argument for custom argument checking. An ArgumentCaptor will capture the specified argument every time the stubbed function is called.
Captured arguments are stored in chronological order for each function call. When getting an argument you can specify which argument to get (defaults to the first time the function was called)
When getting a captured argument the type must be specified. If the argument can not be cast as the type given then a `fatalError()` will occur.

```swift
let captor = Argument.captor()
fakeStringService.stub(.hereAreTwoStrings).with(Argument.anything, captor).andReturn("stubbed value")

_ = fakeStringService.hereAreTwoStrings(string1: "first arg first call", string2: "second arg first call")
_ = fakeStringService.hereAreTwoStrings(string1: "first arg second call", string2: "second arg second call")

let secondArgFromFirstCall = captor.getValue(as: String.self) // `at:` defaults to `0` or first call
let secondArgFromSecondCall = captor.getValue(at: 1, as: String.self)
// or
let secondArgFromFirstCall: String = captor[0]
let secondArgFromSecondCall: String = captor[1]
```

## Contributing

If you have an idea that can make SpryKit better, please don't hesitate to submit a pull request!
