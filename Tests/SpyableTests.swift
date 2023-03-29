import Foundation
import NSpry
import XCTest

final class SpyableTests: XCTestCase {
    let subject: SpyableTestHelper = .init()

    override func setUp() {
        super.setUp()
        subject.resetCalls()
        SpyableTestHelper.resetCalls()
    }

    func test_resetting_calls() {
        subject.doStuff()
        subject.resetCalls()
        subject.doStuffWith(string: "")

        XCTAssertFalse(subject.didCall(.doStuff).success)
        XCTAssertTrue(subject.didCall(.doStuffWithString).success)
    }

    func test_on_the_class() {
        SpyableTestHelper.doClassStuff()
        SpyableTestHelper.resetCalls()
        SpyableTestHelper.doClassStuffWith(string: "")

        XCTAssertFalse(SpyableTestHelper.didCall(.doClassStuff).success)
        XCTAssertTrue(SpyableTestHelper.didCall(.doClassStuffWith).success)
    }

    func test_set_property() {
        let newValue = "new value"
        subject.ivarProperty = newValue
        XCTAssertTrue(subject.didCall(.ivarProperty).success)
        XCTAssertTrue(subject.didCall(.ivarProperty, withArguments: [newValue]).success)
    }

    func test_call_function() {
        subject.doStuff()
        XCTAssertTrue(subject.didCall(.doStuff).success)
        XCTAssertFalse(subject.didCall(.doStuffWithString).success)
    }

    func test_call_function_no_args_count_specifier() {
        let getSuccessValue: (CountSpecifier) -> Bool = { countSpecifier in
            return self.subject.didCall(.doStuff, countSpecifier: countSpecifier).success
        }
        subject.doStuff()
        subject.doStuff()

        XCTAssertFalse(getSuccessValue(.exactly(1)))
        XCTAssertTrue(getSuccessValue(.exactly(2)))
        XCTAssertFalse(getSuccessValue(.exactly(3)))

        XCTAssertTrue(getSuccessValue(.atLeast(1)))
        XCTAssertTrue(getSuccessValue(.atLeast(2)))
        XCTAssertFalse(getSuccessValue(.atLeast(3)))

        XCTAssertFalse(getSuccessValue(.atMost(1)))
        XCTAssertTrue(getSuccessValue(.atMost(2)))
        XCTAssertTrue(getSuccessValue(.atMost(3)))
    }

    func test_call_function_no_count_specifier() {
        let actualString = "actual string"
        subject.doStuffWith(string: actualString)
        XCTAssertTrue(subject.didCall(.doStuffWithString, withArguments: [actualString]).success)
        XCTAssertFalse(subject.didCall(.doStuffWithString, withArguments: ["wrong string"]).success)
    }

    func test_call_function_with_args_count_specifier() {
        let actualString = "correct string"
        let getSuccessValue: (CountSpecifier) -> Bool = { countSpecifier in
            return self.subject.didCall(.doStuffWithString, withArguments: [actualString], countSpecifier: countSpecifier).success
        }
        subject.doStuffWith(string: actualString)
        subject.doStuffWith(string: "wrong string")
        subject.doStuffWith(string: actualString)

        XCTAssertFalse(getSuccessValue(.exactly(1)))
        XCTAssertTrue(getSuccessValue(.exactly(2)))
        XCTAssertFalse(getSuccessValue(.exactly(3)))

        XCTAssertTrue(getSuccessValue(.atLeast(1)))
        XCTAssertTrue(getSuccessValue(.atLeast(2)))
        XCTAssertFalse(getSuccessValue(.atLeast(3)))

        XCTAssertFalse(getSuccessValue(.atMost(1)))
        XCTAssertTrue(getSuccessValue(.atMost(2)))
        XCTAssertTrue(getSuccessValue(.atMost(3)))
    }

    func test_call_class_function() {
        let actualArgument = "correct string"
        SpyableTestHelper.doClassStuffWith(string: actualArgument)
        XCTAssertTrue(SpyableTestHelper.didCall(.doClassStuffWith).success)
        XCTAssertTrue(SpyableTestHelper.didCall(.doClassStuffWith, withArguments: [actualArgument]).success)
        XCTAssertTrue(SpyableTestHelper.didCall(.doClassStuffWith, countSpecifier: .exactly(1)).success)
        XCTAssertTrue(SpyableTestHelper.didCall(.doClassStuffWith, withArguments: [actualArgument], countSpecifier: .exactly(1)).success)
        XCTAssertFalse(SpyableTestHelper.didCall(.doClassStuff).success)
    }

    func test_result_recordedCallsDescription() {
        XCTAssertEqual(subject.didCall(.doStuff).recordedCallsDescription, "<>")

        subject.doStuff()
        XCTAssertEqual(subject.didCall(.doStuff).recordedCallsDescription, "<\(SpyableTestHelper.Function.doStuff.rawValue)>")

        let firstArg = 1
        let secondArg = 2

        subject.resetCalls()
        subject.doStuffWith(int1: firstArg, int2: secondArg)
        let expectedDescription = "<\(SpyableTestHelper.Function.doStuffWithInts.rawValue)> with <\(firstArg)>, <\(secondArg)>"
        XCTAssertEqual(subject.didCall(.doStuff).recordedCallsDescription, expectedDescription)

        subject.resetCalls()
        subject.doStuff()
        subject.doStuffWith(int1: firstArg, int2: secondArg)
        let expectedDescription2 = "<\(SpyableTestHelper.Function.doStuff.rawValue)>; <\(SpyableTestHelper.Function.doStuffWithInts.rawValue)> with <\(firstArg)>, <\(secondArg)>"
        XCTAssertEqual(subject.didCall(.doStuff).recordedCallsDescription, expectedDescription2)
    }
}
