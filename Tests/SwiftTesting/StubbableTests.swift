#if canImport(Testing)
import Foundation
import SpryKit
import Testing

@Suite("Stubbable Tests", .serialized)
final class StubbableTests {
    let subject: StubbableTestHelper = .init()

    deinit {
        StubbableTestHelper.resetStubs()
    }

    @Test("Return void")
    func return_void() {
        subject.stub(.giveMeAVoid).andReturn()
        // Void function returns (), so we just call it to verify it doesn't crash
        subject.giveMeAVoid()

        subject.stubAgain(.giveMeAVoid).andReturn(())
        // Void function returns (), so we just call it to verify it doesn't crash
        subject.giveMeAVoid()
    }

    @Test("Return string")
    func return_string() {
        let expectedString = "expected"
        subject.stub(.giveMeAString).andReturn(expectedString)
        #expect(subject.giveMeAString() == expectedString)
    }

    @Test("Return tuple")
    func return_tuple() {
        subject.stub(.hereComesATuple).andReturn(("hello", "world"))
        let tuple = subject.hereComesATuple()
        #expect(tuple.0 == "hello")
        #expect(tuple.1 == "world")
    }

    @Test("Return object")
    func return_object() {
        let expectedValue = NumbersOnly(value: 123)
        subject.stub(.hereComesAProtocol).andReturn(expectedValue)
        let specialString = subject.hereComesAProtocol()
        #expect(specialString.myStringValue() == expectedValue.myStringValue())
    }

    @Test("Return protocol")
    func return_protocol() {
        let expectedValue = "hello there"
        let specialString = StubSpecialString()
        specialString.stub(.myStringValue).andReturn(expectedValue)
        subject.stub(.hereComesAProtocol).andReturn(specialString)

        let actualString = subject.hereComesAProtocol()
        #expect(actualString.myStringValue() == expectedValue)
    }

    @Test("Return tuple of protocols")
    func return_tuple_of_protocols() {
        let expectedFirstHalf = NumbersOnly(value: 1)
        let expectedSecondHalf = "two"
        let secondHalfSpecialString = StubSpecialString()
        secondHalfSpecialString.stub(.myStringValue).andReturn(expectedSecondHalf)
        subject.stub(.hereComesProtocolsInATuple).andReturn((expectedFirstHalf, secondHalfSpecialString))

        let tuple = subject.hereComesProtocolsInATuple()
        #expect(tuple.0.myStringValue() == expectedFirstHalf.myStringValue())
        #expect(tuple.1.myStringValue() == expectedSecondHalf)
    }

    @Test("Return protocol with self requirement implemented")
    func return_protocolWithSelfRequirementImplemented() {
        let expectedMyClass = ProtocolWithSelfRequirementImplemented()
        subject.stub(.hereComesProtocolWithSelfRequirements).andReturn(expectedMyClass)
        let actualMyClass = subject.hereComesProtocolWithSelfRequirements(object: ProtocolWithSelfRequirementImplemented())
        #expect(actualMyClass === expectedMyClass)
    }

    @Test("Return closure")
    func return_closure() {
        let expectedString = "string from closure"
        subject.stub(.hereComesAClosure).andReturn {
            return expectedString
        }
        let closure = subject.hereComesAClosure()
        #expect(closure() == expectedString)
    }

    @Test("Return optional")
    func return_optional() {
        let expectedReturn: String? = "i should be returned"
        subject.stub(.giveMeAnOptional).andReturn(expectedReturn)
        #expect(subject.giveMeAnOptional() == expectedReturn)
    }

    @Test("Return non optional")
    func return_non_optional() {
        let expectedReturn = "i should be returned"
        subject.stub(.giveMeAnOptional).andReturn(expectedReturn)
        #expect(subject.giveMeAnOptional() == expectedReturn)
    }

    @Test("Return nil")
    func return_nil() {
        subject.stub(.giveMeAnOptional).andReturn(nil)
        #expect(subject.giveMeAnOptional() == nil)
    }

    @Test("Do no args")
    func do_no_args() {
        let expectedString = "expected"
        subject.stub(.giveMeAString).andDo { _ in
            expectedString
        }
        #expect(subject.giveMeAString() == expectedString)
    }

    @Test("Do 1 arg")
    func do_1_arg() {
        let expectedString = "expected"
        subject.stub(.takeUnnamedArgument).andDo { arguments in
            let string = arguments[0] as! String
            return string == expectedString
        }
        #expect(subject.takeUnnamedArgument(expectedString))
    }

    @Test("Do 2 args and return value")
    func do_2_args_and_return_value() {
        subject.stub(.hereAreTwoStrings).andDo { arguments in
            let string1 = arguments[0] as! String
            let string2 = arguments[1] as! String

            return string1 == "one" && string2 == "two"
        }
        #expect(subject.hereAreTwoStrings(string1: "one", string2: "two"))
    }

    @Test("Do manually manipulating arguments")
    func do_manually_manipulating_agruments() {
        var turnToTrue = false
        subject.stub(.callThisCompletion).andDo { arguments in
            let completion = arguments[1] as! () -> Void
            completion()
            return ()
        }
        subject.callThisCompletion(string: "") {
            turnToTrue = true
        }
        #expect(turnToTrue)
    }

    @Test("Throw")
    func throw_test() {
        let stubbedError = StubbableError(id: "my error")
        subject.stub(.throwingFunction).andThrow(stubbedError)
        expectThrows(stubbedError) {
            try subject.throwingFunction()
        }
    }

    @Test("Cant throw")
    func cant_throw() {
        let stubbedError = StubbableError(id: "my error")
        subject.stub(.giveMeAString).andThrow(stubbedError)
        expectThrowsAssertion { [subject] in
            subject.giveMeAString()
        }
    }

    @Test("Stubbing property")
    func stubbing_property() {
        let expectedString = "expected"
        subject.stub(.myProperty).andReturn(expectedString)
        #expect(subject.myProperty == expectedString)
    }

    @Test("Stubbing class function")
    func stubbing_class_function() {
        let expectedString = "expected"
        StubbableTestHelper.stub(.classFunction).andReturn(expectedString)
        #expect(StubbableTestHelper.classFunction() == expectedString)
    }

    @Test("Passing in arguments when the arguments match what is stubbed")
    func passing_in_arguments_when_the_arguments_match_what_is_stubbed() {
        let expectedArg = "im expected"
        let expectedReturn = "i should be returned"
        subject.stub(.giveMeAString_string).with(expectedArg).andReturn(expectedReturn)
        #expect(subject.giveMeAString(string: expectedArg) == expectedReturn)
    }

    @Test("Passing in arguments when the arguments match what is stubbed list")
    func passing_in_arguments_when_the_arguments_match_what_is_stubbed_list() {
        let expectedArg = ["im expected 1", "im expected 2"]
        let expectedReturn = ["i should be returned 1", "i should be returned 2"]

        for (arg, ret) in zip(expectedArg, expectedReturn) {
            subject.stub(.giveMeAString_string).with(arg).andReturn(ret)
        }

        for (arg, ret) in zip(expectedArg, expectedReturn) {
            #expect(subject.giveMeAString(string: arg) == ret)
        }
    }

    @Test("Passing in arguments when the arguments match what is stubbed list mixed")
    func passing_in_arguments_when_the_arguments_match_what_is_stubbed_list_mixed() {
        let expectedArg: [(str: String, url: URL)] = [
            ("im expected 1", URL(string: "google.com/1")!),
            ("im expected 2", URL(string: "google.com/2")!)
        ]

        let expectedReturn = ["i should be returned 1", "i should be returned 2"]

        for (arg, ret) in zip(expectedArg, expectedReturn) {
            subject.stub(.giveMeAString_string_url).with(Argument.anything, arg.url).andReturn(ret)
        }

        for (arg, ret) in zip(expectedArg, expectedReturn) {
            #expect(subject.giveMeAString(string: arg.str, and: arg.url) == ret)
        }
    }

    @Test("Passing in arguments when the arguments match what is stubbed list 2args")
    func passing_in_arguments_when_the_arguments_match_what_is_stubbed_list_2args() {
        let expectedArg: [(str: String, url: URL)] = [
            ("im expected 1", URL(string: "google.com/1")!),
            ("im expected 2", URL(string: "google.com/2")!)
        ]

        let expectedReturn = ["i should be returned 1", "i should be returned 2"]

        for (arg, ret) in zip(expectedArg, expectedReturn) {
            subject.stub(.giveMeAString_string_url).with(arg.str, arg.url).andReturn(ret)
        }

        for (arg, ret) in zip(expectedArg, expectedReturn) {
            #expect(subject.giveMeAString(string: arg.str, and: arg.url) == ret)
        }
    }

    @Test("Passing in arguments when the arguments match what is stubbed list 2args enum equatable only")
    func passing_in_arguments_when_the_arguments_match_what_is_stubbed_list_2args_enum_equatableonly() {
        let expectedArg: [(str: String, obj: EqValue)] = [
            ("im expected 1", .one),
            ("im expected 2", .two)
        ]

        let expectedReturn = ["i should be returned 1", "i should be returned 2"]

        for (arg, ret) in zip(expectedArg, expectedReturn) {
            subject.stub(.giveMeAString_string_url).with(arg.str, arg.obj).andReturn(ret)
        }

        for (arg, ret) in zip(expectedArg, expectedReturn) {
            #expect(subject.giveMeAString(string: arg.str, and: arg.obj) == ret)
        }
    }

    @Test("Passing in arguments when the arguments match what is stubbed list 2args struct equatable only")
    func passing_in_arguments_when_the_arguments_match_what_is_stubbed_list_2args_struct_equatableonly() {
        let expectedArg: [(str: String, obj: EqValue2)] = [
            ("im expected 1", .one),
            ("im expected 2", .two)
        ]

        let expectedReturn = ["i should be returned 1", "i should be returned 2"]

        for (arg, ret) in zip(expectedArg, expectedReturn) {
            subject.stub(.giveMeAString_string_url).with(arg.str, arg.obj).andReturn(ret)
        }

        for (arg, ret) in zip(expectedArg, expectedReturn) {
            #expect(subject.giveMeAString(string: arg.str, and: arg.obj) == ret)
        }
    }

    @Test("Passing in arguments when the arguments do NOT match what is stubbed")
    func passing_in_arguments_when_the_arguments_do_NOT_match_what_is_stubbed() {
        subject.stub(.giveMeAString_string).with("not expected").andReturn("return value")
        expectThrowsAssertion { [subject] in
            subject.giveMeAString(string: "blah")
        }
    }

    @Test("Passing in arguments when there are no arguments passed in")
    func passing_in_arguments_when_there_are_no_arguments_passed_in() {
        let expectedReturn = "i should be returned"
        subject.stub(.giveMeAString_string).andReturn(expectedReturn)
        #expect(subject.giveMeAString(string: "doesn't matter") == expectedReturn)
    }

    @Test("Argument capture")
    func argument_capture() {
        let firstArg = "first arg"
        let secondArg = "second arg"
        let correctSecondString = "correct second string"
        let argumentCaptor = Argument.captor()

        subject.stub(.hereAreTwoStrings).with(argumentCaptor, correctSecondString).andReturn(true)
        subject.stub(.hereAreTwoStrings).andReturn(true)

        _ = subject.hereAreTwoStrings(string1: firstArg, string2: correctSecondString)
        _ = subject.hereAreTwoStrings(string1: "shouldn't capture me", string2: "wrong argument")
        _ = subject.hereAreTwoStrings(string1: secondArg, string2: correctSecondString)

        #expect(argumentCaptor.getValue(as: String.self) == firstArg)
        #expect(argumentCaptor.getValue(at: 1, as: String.self) == secondArg)
    }

    @Test("Fallback value when the function is stubbed with the appropriate type")
    func fallback_value_when_the_function_is_stubbed_with_the_appropriate_type() {
        let expectedString = "stubbed value"
        subject.stub(.giveMeAStringWithFallbackValue).andReturn(expectedString)
        #expect(subject.giveMeAStringWithFallbackValue() == expectedString)
    }

    @Test("Fallback value when the function is NOT stubbed with the appropriate type")
    func fallback_value_when_the_function_is_NOT_stubbed_with_the_appropriate_type() {
        let fallbackValue = "fallback value"
        subject.fallbackValueForgiveMeAStringWithFallbackValue = fallbackValue
        subject.stub(.giveMeAStringWithFallbackValue).andReturn(100)
        #expect(subject.giveMeAStringWithFallbackValue() == fallbackValue)
    }

    @Test("Fallback value when the function is NOT stubbed")
    func fallback_value_when_the_function_is_NOT_stubbed() {
        let fallbackValue = "fallback value"
        subject.fallbackValueForgiveMeAStringWithFallbackValue = fallbackValue
        #expect(subject.giveMeAStringWithFallbackValue() == fallbackValue)
    }

    @Test("Fallback value when the fallback value is nil")
    func fallback_value_when_the_fallback_value_is_nil() {
        subject.fallbackValueForgiveMeAStringWithFallbackValue = nil
        #expect(subject.giveMeAStringWithFallbackValue() == nil)
    }

    @Test("Improper stubbing without a fallback value")
    func improper_stubbing_without_a_fallback_value() {
        expectThrowsAssertion { [subject] in
            subject.giveMeAString()
        }
    }

    @Test("When the value is stubbed with the wrong type")
    func when_the_value_is_stubbed_with_the_wrong_type() {
        subject.stub(.giveMeAString).andReturn(50)
        expectThrowsAssertion { [subject] in
            subject.giveMeAString()
        }
    }

    @Test("Resetting stubs")
    func resetting_stubs() {
        subject.stub(.giveMeAString).andReturn("fallbackValue")
        subject.resetStubs()

        expectThrowsAssertion { [subject] in
            subject.giveMeAString()
        }

        subject.stub(.giveMeAString).andReturn("fallbackValue")
        #expect(subject.giveMeAString() == "fallbackValue")
    }

    @Test("On a class")
    func on_a_class() {
        StubbableTestHelper.stub(.classFunction).andReturn("fallbackValue")
        StubbableTestHelper.resetStubs()

        expectThrowsAssertion {
            _ = StubbableTestHelper.classFunction()
        }

        StubbableTestHelper.stub(.classFunction).andReturn("fallbackValue")
        #expect(StubbableTestHelper.classFunction() == "fallbackValue")
    }

    @Test("Stubbing again using with")
    func stubbing_again_using_with() {
        let originalString = "original string"
        subject.stub(.giveMeAString_string).with(originalString).andReturn("original return value")
        subject.stub(.giveMeAString_string).with("different string").andReturn("other return value")

        expectThrowsAssertion { [subject] in
            subject.stub(.giveMeAString_string).with(originalString).andReturn("other return value")
        }

        let newReturnValue = "new return value"
        subject.stubAgain(.giveMeAString_string).with(originalString).andReturn(newReturnValue)
        #expect(subject.giveMeAString(string: originalString) == newReturnValue)
    }

    @Test("Stubbing again without with")
    func stubbing_again_without_with() {
        subject.stub(.giveMeAString_string).andReturn("original return value")

        expectThrowsAssertion { [subject] in
            subject.stub(.giveMeAString_string).andReturn("other return value")
        }

        let newReturnValue = "new return value"
        subject.stubAgain(.giveMeAString_string).andReturn(newReturnValue)
        #expect(subject.giveMeAString(string: "blah") == newReturnValue)
    }

    @Test("Class version spot check")
    func class_version_spot_check() {
        StubbableTestHelper.stub(.classFunction).andReturn("original return value")

        // Use closure version - autoclosure doesn't work reliably with catchBadInstruction in parallel execution
        // The fatalError is triggered synchronously when andReturn() sets stubType via didSet
        expectThrowsAssertion {
            _ = StubbableTestHelper.stub(.classFunction).andReturn("original return value")
        }

        let newReturnValue = "new return value"
        StubbableTestHelper.stubAgain(.classFunction).andReturn(newReturnValue)
        #expect(StubbableTestHelper.classFunction() == newReturnValue)
    }
}

private extension StubbableTests {
    enum EqValue: Equatable {
        case one
        case two
    }

    struct EqValue2: Equatable {
        let v: String

        static let one: Self = .init(v: "one")
        static let two: Self = .init(v: "two")
    }
}
#endif // canImport(Testing)
