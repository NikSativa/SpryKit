import Foundation
import NSpry
import XCTest

final class StubbableTests: XCTestCase {
    let subject: StubbableTestHelper = .init()

    override func tearDown() {
        super.tearDown()
        subject.resetStubs()
        StubbableTestHelper.resetStubs()
    }

    func test_return_void() {
        subject.stub(.giveMeAVoid).andReturn()
        XCTAssertNotNil(subject.giveMeAVoid())

        subject.stubAgain(.giveMeAVoid).andReturn(())
        XCTAssertNotNil(subject.giveMeAVoid())
    }

    func test_return_string() {
        let expectedString = "expected"
        subject.stub(.giveMeAString).andReturn(expectedString)
        XCTAssertEqual(subject.giveMeAString(), expectedString)
    }

    func test_return_tuple() {
        subject.stub(.hereComesATuple).andReturn(("hello", "world"))
        let tuple = subject.hereComesATuple()
        XCTAssertEqual(tuple.0, "hello")
        XCTAssertEqual(tuple.1, "world")
    }

    func test_return_object() {
        let expectedValue = NumbersOnly(value: 123)
        subject.stub(.hereComesAProtocol).andReturn(expectedValue)
        let specialString = subject.hereComesAProtocol()
        XCTAssertEqual(specialString.myStringValue(), expectedValue.myStringValue())
    }

    func test_return_protocol() {
        let expectedValue = "hello there"
        let specialString = StubSpecialString()
        specialString.stub(.myStringValue).andReturn(expectedValue)
        subject.stub(.hereComesAProtocol).andReturn(specialString)

        let actualString = subject.hereComesAProtocol()
        XCTAssertEqual(actualString.myStringValue(), expectedValue)
    }

    func test_return_tuple_of_protocols() {
        let expectedFirstHalf = NumbersOnly(value: 1)
        let expectedSecondHalf = "two"
        let secondHalfSpecialString = StubSpecialString()
        secondHalfSpecialString.stub(.myStringValue).andReturn(expectedSecondHalf)
        subject.stub(.hereComesProtocolsInATuple).andReturn((expectedFirstHalf, secondHalfSpecialString))

        let tuple = subject.hereComesProtocolsInATuple()
        XCTAssertEqual(tuple.0.myStringValue(), expectedFirstHalf.myStringValue())
        XCTAssertEqual(tuple.1.myStringValue(), expectedSecondHalf)
    }

    func test_return_protocolWithSelfRequirementImplemented() {
        let expectedMyClass = ProtocolWithSelfRequirementImplemented()
        subject.stub(.hereComesProtocolWithSelfRequirements).andReturn(expectedMyClass)
        let actualMyClass = subject.hereComesProtocolWithSelfRequirements(object: ProtocolWithSelfRequirementImplemented())
        XCTAssertTrue(actualMyClass === expectedMyClass)
    }

    func test_return_closure() {
        let expectedString = "string from closure"
        // swiftformat:disable:next all
        subject.stub(.hereComesAClosure).andReturn({
            return expectedString
        })
        let closure = subject.hereComesAClosure()
        XCTAssertEqual(closure(), expectedString)
    }

    func test_return_optional() {
        let expectedReturn: String? = "i should be returned"
        subject.stub(.giveMeAnOptional).andReturn(expectedReturn)
        XCTAssertEqual(subject.giveMeAnOptional(), expectedReturn)
    }

    func test_return_non_optional() {
        let expectedReturn = "i should be returned"
        subject.stub(.giveMeAnOptional).andReturn(expectedReturn)
        XCTAssertEqual(subject.giveMeAnOptional(), expectedReturn)
    }

    func test_return_nil() {
        subject.stub(.giveMeAnOptional).andReturn(nil)
        XCTAssertNil(subject.giveMeAnOptional())
    }

    func test_do_no_args() {
        let expectedString = "expected"
        subject.stub(.giveMeAString).andDo { _ in
            return expectedString
        }
        XCTAssertEqual(subject.giveMeAString(), expectedString)
    }

    func test_do_1_arg() {
        let expectedString = "expected"
        subject.stub(.takeUnnamedArgument).andDo { arguments in
            let string = arguments[0] as! String
            return string == expectedString
        }
        XCTAssertTrue(subject.takeUnnamedArgument(expectedString))
    }

    func test_do_2_args_and_return_value() {
        subject.stub(.hereAreTwoStrings).andDo { arguments in
            let string1 = arguments[0] as! String
            let string2 = arguments[1] as! String

            return string1 == "one" && string2 == "two"
        }
        XCTAssertTrue(subject.hereAreTwoStrings(string1: "one", string2: "two"))
    }

    /// manually manipulating agruments (such as passed in closures)
    func test_do_manually_manipulating_agruments() {
        var turnToTrue = false
        subject.stub(.callThisCompletion).andDo { arguments in
            let completion = arguments[1] as! () -> Void
            completion()
            return ()
        }
        subject.callThisCompletion(string: "") {
            turnToTrue = true
        }
        XCTAssertTrue(turnToTrue)
    }

    func test_throw() {
        let stubbedError = StubbableError(id: "my error")
        subject.stub(.throwingFunction).andThrow(stubbedError)
        XCTAssertThrowsError(try subject.throwingFunction(), stubbedError)
    }

    func test_cant_throw() {
        let stubbedError = StubbableError(id: "my error")
        subject.stub(.giveMeAString).andThrow(stubbedError)
        XCTAssertThrowsAssertion {
            self.subject.giveMeAString()
        }
    }

    func test_stubbing_property() {
        let expectedString = "expected"
        subject.stub(.myProperty).andReturn(expectedString)
        XCTAssertEqual(subject.myProperty, expectedString)
    }

    func test_stubbing_class_function() {
        let expectedString = "expected"
        StubbableTestHelper.stub(.classFunction).andReturn(expectedString)
        XCTAssertEqual(StubbableTestHelper.classFunction(), expectedString)
    }

    func test_passing_in_arguments_when_the_arguments_match_what_is_stubbed() {
        let expectedArg = "im expected"
        let expectedReturn = "i should be returned"
        subject.stub(.giveMeAString_string).with(expectedArg).andReturn(expectedReturn)
        XCTAssertEqual(subject.giveMeAString(string: expectedArg), expectedReturn)
    }

    func test_passing_in_arguments_when_the_arguments_match_what_is_stubbed_list() {
        let expectedArg = ["im expected 1", "im expected 2"]
        let expectedReturn = ["i should be returned 1", "i should be returned 2"]

        for (arg, ret) in zip(expectedArg, expectedReturn) {
            subject.stub(.giveMeAString_string).with(arg).andReturn(ret)
        }

        for (arg, ret) in zip(expectedArg, expectedReturn) {
            XCTAssertEqual(subject.giveMeAString(string: arg), ret)
        }
    }

    func test_passing_in_arguments_when_the_arguments_match_what_is_stubbed_list_mixed() {
        let expectedArg: [(str: String, url: URL)] = [
            ("im expected 1", URL(string: "google.com/1")!),
            ("im expected 2", URL(string: "google.com/2")!)
        ]

        let expectedReturn = ["i should be returned 1", "i should be returned 2"]

        for (arg, ret) in zip(expectedArg, expectedReturn) {
            subject.stub(.giveMeAString_string_url).with(Argument.anything, arg.url).andReturn(ret)
        }

        for (arg, ret) in zip(expectedArg, expectedReturn) {
            XCTAssertEqual(subject.giveMeAString(string: arg.str, and: arg.url), ret)
        }
    }

    func test_passing_in_arguments_when_the_arguments_match_what_is_stubbed_list_2args() {
        let expectedArg: [(str: String, url: URL)] = [
            ("im expected 1", URL(string: "google.com/1")!),
            ("im expected 2", URL(string: "google.com/2")!)
        ]

        let expectedReturn = ["i should be returned 1", "i should be returned 2"]

        for (arg, ret) in zip(expectedArg, expectedReturn) {
            subject.stub(.giveMeAString_string_url).with(arg.str, arg.url).andReturn(ret)
        }

        for (arg, ret) in zip(expectedArg, expectedReturn) {
            XCTAssertEqual(subject.giveMeAString(string: arg.str, and: arg.url), ret)
        }
    }

    func test_passing_in_arguments_when_the_arguments_match_what_is_stubbed_list_2args_enum_equatableonly() {
        let expectedArg: [(str: String, obj: EqValue)] = [
            ("im expected 1", .one),
            ("im expected 2", .two)
        ]

        let expectedReturn = ["i should be returned 1", "i should be returned 2"]

        for (arg, ret) in zip(expectedArg, expectedReturn) {
            subject.stub(.giveMeAString_string_url).with(arg.str, arg.obj).andReturn(ret)
        }

        for (arg, ret) in zip(expectedArg, expectedReturn) {
            XCTAssertEqual(subject.giveMeAString(string: arg.str, and: arg.obj), ret)
        }
    }

    func test_passing_in_arguments_when_the_arguments_match_what_is_stubbed_list_2args_struct_equatableonly() {
        let expectedArg: [(str: String, obj: EqValue2)] = [
            ("im expected 1", .one),
            ("im expected 2", .two)
        ]

        let expectedReturn = ["i should be returned 1", "i should be returned 2"]

        for (arg, ret) in zip(expectedArg, expectedReturn) {
            subject.stub(.giveMeAString_string_url).with(arg.str, arg.obj).andReturn(ret)
        }

        for (arg, ret) in zip(expectedArg, expectedReturn) {
            XCTAssertEqual(subject.giveMeAString(string: arg.str, and: arg.obj), ret)
        }
    }

    func test_passing_in_arguments_when_the_arguments_do_NOT_match_what_is_stubbed() {
        subject.stub(.giveMeAString_string).with("not expected").andReturn("return value")
        XCTAssertThrowsAssertion {
            self.subject.giveMeAString(string: "blah")
        }
    }

    func test_passing_in_arguments_when_there_are_no_arguments_passed_in() {
        let expectedReturn = "i should be returned"
        subject.stub(.giveMeAString_string).andReturn(expectedReturn)
        XCTAssertEqual(subject.giveMeAString(string: "doesn't matter"), expectedReturn)
    }

    func test_argument_capture() {
        let firstArg = "first arg"
        let secondArg = "second arg"
        let correctSecondString = "correct second string"
        let argumentCaptor = Argument.captor()

        subject.stub(.hereAreTwoStrings).with(argumentCaptor, correctSecondString).andReturn(true)
        subject.stub(.hereAreTwoStrings).andReturn(true)

        _ = subject.hereAreTwoStrings(string1: firstArg, string2: correctSecondString)
        _ = subject.hereAreTwoStrings(string1: "shouldn't capture me", string2: "wrong argument")
        _ = subject.hereAreTwoStrings(string1: secondArg, string2: correctSecondString)

        XCTAssertEqual(argumentCaptor.getValue(as: String.self), firstArg)
        XCTAssertEqual(argumentCaptor.getValue(at: 1, as: String.self), secondArg)
    }

    func test_fallback_value_when_the_function_is_stubbed_with_the_appropriate_type() {
        let expectedString = "stubbed value"
        subject.stub(.giveMeAStringWithFallbackValue).andReturn(expectedString)
        XCTAssertEqual(subject.giveMeAStringWithFallbackValue(), expectedString)
    }

    func test_fallback_value_when_the_function_is_NOT_stubbed_with_the_appropriate_type() {
        let fallbackValue = "fallback value"
        subject.fallbackValueForgiveMeAStringWithFallbackValue = fallbackValue
        subject.stub(.giveMeAStringWithFallbackValue).andReturn(100)
        XCTAssertEqual(subject.giveMeAStringWithFallbackValue(), fallbackValue)
    }

    func test_fallback_value_when_the_function_is_NOT_stubbed() {
        let fallbackValue = "fallback value"
        subject.fallbackValueForgiveMeAStringWithFallbackValue = fallbackValue
        XCTAssertEqual(subject.giveMeAStringWithFallbackValue(), fallbackValue)
    }

    func test_fallback_value_when_the_fallback_value_is_nil() {
        subject.fallbackValueForgiveMeAStringWithFallbackValue = nil
        XCTAssertNil(subject.giveMeAStringWithFallbackValue())
    }

    func test_improper_stubbing_without_a_fallback_value() {
        XCTAssertThrowsAssertion {
            self.subject.giveMeAString()
        }
    }

    func test_when_the_value_is_stubbed_with_the_wrong_type() {
        subject.stub(.giveMeAString).andReturn(50)
        XCTAssertThrowsAssertion {
            self.subject.giveMeAString()
        }
    }

    func test_resetting_stubs() {
        subject.stub(.giveMeAString).andReturn("fallbackValue")
        subject.resetStubs()
        XCTAssertThrowsAssertion {
            self.subject.giveMeAString()
        }

        subject.stub(.giveMeAString).andReturn("fallbackValue")
        XCTAssertEqual(subject.giveMeAString(), "fallbackValue")
    }

    func test_on_a_class() {
        StubbableTestHelper.stub(.classFunction).andReturn("fallbackValue")
        StubbableTestHelper.resetStubs()
        XCTAssertThrowsAssertion(StubbableTestHelper.classFunction())

        StubbableTestHelper.stub(.classFunction).andReturn("fallbackValue")
        XCTAssertEqual(StubbableTestHelper.classFunction(), "fallbackValue")
    }

    func test_stubbing_again_using_with() {
        let originalString = "original string"
        subject.stub(.giveMeAString_string).with(originalString).andReturn("original return value")
        subject.stub(.giveMeAString_string).with("different string").andReturn("other return value")
        XCTAssertThrowsAssertion {
            self.subject.stub(.giveMeAString_string).with(originalString).andReturn("other return value")
        }

        let newReturnValue = "new return value"
        subject.stubAgain(.giveMeAString_string).with(originalString).andReturn(newReturnValue)
        XCTAssertEqual(subject.giveMeAString(string: originalString), newReturnValue)
    }

    func test_stubbing_again_without_with() {
        subject.stub(.giveMeAString_string).andReturn("original return value")
        XCTAssertThrowsAssertion {
            self.subject.stub(.giveMeAString_string).andReturn("other return value")
        }

        let newReturnValue = "new return value"
        subject.stubAgain(.giveMeAString_string).andReturn(newReturnValue)
        XCTAssertEqual(subject.giveMeAString(string: "blah"), newReturnValue)
    }

    func test_class_version_spot_check() {
        StubbableTestHelper.stub(.classFunction).andReturn("original return value")
        XCTAssertThrowsAssertion(StubbableTestHelper.stub(.classFunction).andReturn("original return value"))

        let newReturnValue = "new return value"
        StubbableTestHelper.stubAgain(.classFunction).andReturn(newReturnValue)
        XCTAssertEqual(StubbableTestHelper.classFunction(), newReturnValue)
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
