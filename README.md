# SpryKit

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FNikSativa%2FSpryKit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/NikSativa/SpryKit)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FNikSativa%2FSpryKit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/NikSativa/SpryKit)

SpryKit is a powerful Swift testing framework that provides spying and stubbing capabilities, making it easier to write clean and maintainable unit tests. It's designed to help you test classes in isolation by verifying method calls and controlling return values.

> [!IMPORTANT]
> SpryKit is thread-safe and can be used in a multi-threaded environment.

## Features

- 🎯 **Spying**: Record and verify method calls and their arguments
- 🎭 **Stubbing**: Control method return values for testing different scenarios
- 🚀 **Macro Support**: Reduce boilerplate with Swift 6.0+ macros
- 🔒 **Thread Safety**: Built-in support for multi-threaded environments
- 📱 **Cross-Platform**: Support for iOS, macOS, tvOS, watchOS, and visionOS
- 🧪 **Rich Assertions**: Comprehensive set of XCTest assertions
- 🔍 **Argument Capturing**: Capture and inspect method arguments
- 🎨 **Image Testing**: Built-in support for image comparison testing

## Requirements

- iOS 13.0+
- macOS 11.0+
- macCatalyst 13.0+
- tvOS 13.0+
- watchOS 6.0+
- visionOS 1.0+
- Swift 5.8+

## Installation

### Swift Package Manager

Add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/NikSativa/SpryKit.git", from: "1.0.0")
]
```

## Quick Start

### 1. Create a Protocol or Class to Test

```swift
protocol UserService {
    func fetchUser(id: String) -> User
    var currentUser: User? { get set }
}
```

### 2. Create a Fake Implementation

#### Using Swift 6.0+ Macros (Recommended)

```swift
@Spryable
final class FakeUserService: UserService {
    @SpryableVar
    var currentUser: User?
    
    @SpryableFunc
    func fetchUser(id: String) -> User
}
```

#### Manual Implementation

```swift
final class FakeUserService: UserService, Spryable {
    enum Function: String, StringRepresentable {
        case currentUser
        case fetchUser = "fetchUser(id:)"
    }
    
    var currentUser: User? {
        get { return stubbedValue() }
        set { recordCall(arguments: newValue) }
    }
    
    func fetchUser(id: String) -> User {
        return spryify(arguments: id)
    }
}
```

### 3. Write Tests

```swift
class UserViewModelTests: XCTestCase {
    var sut: UserViewModel!
    var fakeUserService: FakeUserService!
    
    override func setUp() {
        super.setUp()
        fakeUserService = FakeUserService()
        sut = UserViewModel(userService: fakeUserService)
    }
    
    override func tearDown() {
        fakeUserService.resetCallsAndStubs()
        super.tearDown()
    }
    
    func test_fetchUser_success() {
        // Given
        let expectedUser = User(id: "1", name: "John")
        fakeUserService.stub(.fetchUser).with("1").andReturn(expectedUser)
        
        // When
        sut.fetchUser(id: "1")
        
        // Then
        XCTAssertHaveReceived(fakeUserService, .fetchUser)
        XCTAssertEqual(sut.currentUser, expectedUser)
    }
}
```

## Core Concepts

### Spying

Spying allows you to verify that methods were called with the correct arguments:

```swift
// Verify a method was called
XCTAssertHaveReceived(fakeService, .doSomething)

// Verify with specific arguments
XCTAssertHaveReceived(fakeService, .doSomething, with: "expected argument")

// Verify call count
XCTAssertHaveReceived(fakeService, .doSomething, times: .exactly(2))
```

### Stubbing

Stubbing lets you control what methods return:

```swift
// Simple return value
fakeService.stub(.doSomething).andReturn("test value")

// Conditional return based on arguments
fakeService.stub(.doSomething)
    .with("specific arg")
    .andReturn("special value")

// Custom implementation
fakeService.stub(.doSomething).andDo { arguments in
    let arg = arguments[0] as! String
    return arg.uppercased()
}
```

### Argument Capturing

Capture and inspect arguments passed to methods:

```swift
let captor = Argument.captor()
fakeService.stub(.doSomething).with(Argument.anything, captor).andReturn("value")

// Later in the test
let capturedArg = captor.getValue(as: String.self)
XCTAssertEqual(capturedArg, "expected value")
```

## Advanced Features

### Custom Argument Validation

```swift
let customValidation = Argument.pass { actualArgument -> Bool in
    guard let string = actualArgument as? String else { return false }
    return string.hasPrefix("test")
}

fakeService.stub(.doSomething)
    .with(customValidation)
    .andReturn("validated")
```

### Testing Errors

```swift
// Test throwing functions
XCTAssertThrowsError(try sut.riskyOperation())

// Test specific errors
XCTAssertEqualError(try sut.riskyOperation(), expectedError)
```

### Image Testing

```swift
XCTAssertEqualImage(actualImage, expectedImage)
```

## Best Practices

1. **Use Macros When Possible**
   - Swift 6.0+ macros reduce boilerplate and potential errors
   - They automatically handle function and property implementations

2. **Reset Between Tests**
   - Always call `resetCallsAndStubs()` in `tearDown()`
   - This ensures each test starts with a clean state

3. **Use Argument Captors for Complex Validation**
   - When you need to verify complex arguments
   - When you need to use the captured values later in the test

4. **Leverage Rich Assertion Messages**
   - SpryKit provides detailed failure messages
   - Use them to write more maintainable tests

5. **Test Edge Cases**
   - Use stubbing to test error conditions
   - Test both success and failure paths

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

SpryKit is available under the MIT license. See the LICENSE file for more info.

__Table of Contents__

* [Motivation](#motivation)
* ['Spryable' protocol conformance](#spryable)
    * [generated by macro](#spryable_+_macro)
    * [manually](#spryable_+_manually)
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
* [MacroAvailable](#MacroAvailable)

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

Lets see example

```swift
// The Real Thing can be a protocol
protocol StringService: AnyObject {
    var readonlyProperty: String { get }
    var readwriteProperty: String { set get }
    func doThings()
    func giveMeAString(arg1: Bool, arg2: String) -> String
    static func giveMeAString(arg1: Bool, arg2: String) -> String
}

// The Real Thing can be a class
class RealStringService: StringService {
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
```

### Spryable + Macro

> [!WARNING]
> **Available only for Swift 6.0 and higher.**

> [!TIP]
> [MacroAvailable](#MacroAvailable) - how to handle breaking API changes.

- *Spryable* macro generates Spryable conformance for a class.
- *SpryableFunc* macro generates body for function with correct name and arguments.
- *SpryableVar* macro generates body for property with correct name and accessors.

```swift
@Spryable
final class GeneratedFakeStringService: StringService {
    @SpryableVar
    var readonlyProperty: String

    @SpryableVar(.set)
    var readwriteProperty: String

    @SpryableFunc
    func doThings()

    @SpryableFunc
    func giveMeAString(arg1: Bool, arg2: String) -> String

    @SpryableFunc
    static func giveMeAString(arg1: Bool, arg2: String) -> String
}
```

### Spryable + manually

```swift
// The Fake Class (If the fake is from a class then `override` will be required for each function and property)
final class FakeStringService: StringService, Spryable {
    enum ClassFunction: String, StringRepresentable {  
        case giveMeAStringWithArg1_Arg2 = "giveMeAString(arg1:arg2:)"
    }
    enum Function: String, StringRepresentable { 
        case readonlyProperty
        case readwriteProperty
        case doThings = "doThings()"
        case giveMeAStringWithArg1_Arg2 = "giveMeAString(arg1:arg2:)"
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
        return spryify() 
    }

    func giveMeAString(arg1: Bool, arg2: String) -> String {
        return spryify(arguments: arg1, arg2) 
    }

    static func giveMeAString(arg1: Bool, arg2: String) -> String {
        return spryify(arguments: arg1, arg2) 
    }
}
```

## Stubbable

_Spryable conforms to Stubbable._

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

_Spryable conforms to Spyable._

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

## MacroAvailable

All the ideas described in the following apply to all packages that depend on SpryKit, not only macros.

In order to handle breaking API changes, clients can wrap uses of such APIs in conditional compilation clauses that check MacroAvailable.

```swift
#if canImport(SpryMacroAvailable)
// code to support @Spryable
#else
// code for SpryKit without Macro
#endif
```

## Contributing

If you have an idea that can make SpryKit better, please don't hesitate to submit a pull request!
