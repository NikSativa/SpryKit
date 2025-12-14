import Foundation
import SpryKit
import XCTest

final class SpyableXCTests: XCTestCase {
    private let subject: SpyableTestHelper = .init()

    override func tearDown() {
        super.tearDown()
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

        XCTAssertFalse(SpyableTestHelper.didCall(.doStuff).success)
        XCTAssertTrue(SpyableTestHelper.didCall(.doStuffWithString).success)
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

    func test_call_class_function_no_args_count_specifier() {
        SpyableTestHelper.doClassStuff()
        SpyableTestHelper.doClassStuff()

        XCTAssertHaveNotReceived(SpyableTestHelper.self, .doStuff, countSpecifier: .exactly(1))
        XCTAssertHaveReceived(SpyableTestHelper.self, .doStuff, countSpecifier: .exactly(2))
        XCTAssertHaveNotReceived(SpyableTestHelper.self, .doStuff, countSpecifier: .exactly(3))

        XCTAssertHaveReceived(SpyableTestHelper.self, .doStuff, countSpecifier: .atLeast(1))
        XCTAssertHaveReceived(SpyableTestHelper.self, .doStuff, countSpecifier: .atLeast(2))
        XCTAssertHaveNotReceived(SpyableTestHelper.self, .doStuff, countSpecifier: .atLeast(3))

        XCTAssertHaveNotReceived(SpyableTestHelper.self, .doStuff, countSpecifier: .atMost(1))
        XCTAssertHaveReceived(SpyableTestHelper.self, .doStuff, countSpecifier: .atMost(2))
        XCTAssertHaveReceived(SpyableTestHelper.self, .doStuff, countSpecifier: .atMost(3))
    }

    func test_call_function_no_args_count_specifier() {
        subject.doStuff()
        subject.doStuff()

        XCTAssertHaveNotReceived(subject, .doStuff, countSpecifier: .exactly(1))
        XCTAssertHaveReceived(subject, .doStuff, countSpecifier: .exactly(2))
        XCTAssertHaveNotReceived(subject, .doStuff, countSpecifier: .exactly(3))

        XCTAssertHaveReceived(subject, .doStuff, countSpecifier: .atLeast(1))
        XCTAssertHaveReceived(subject, .doStuff, countSpecifier: .atLeast(2))
        XCTAssertHaveNotReceived(subject, .doStuff, countSpecifier: .atLeast(3))

        XCTAssertHaveNotReceived(subject, .doStuff, countSpecifier: .atMost(1))
        XCTAssertHaveReceived(subject, .doStuff, countSpecifier: .atMost(2))
        XCTAssertHaveReceived(subject, .doStuff, countSpecifier: .atMost(3))
    }

    func test_call_function_no_count_specifier() {
        let actualString = "actual string"
        subject.doStuffWith(string: actualString)
        XCTAssertTrue(subject.didCall(.doStuffWithString, withArguments: [actualString]).success)
        XCTAssertFalse(subject.didCall(.doStuffWithString, withArguments: ["wrong string"]).success)
    }

    func test_call_function_with_args_count_specifier() {
        let actualString = "correct string"
        subject.doStuffWith(string: actualString)
        subject.doStuffWith(string: "other string")
        subject.doStuffWith(string: actualString)

        XCTAssertHaveNotReceived(subject, .doStuffWithString, with: actualString, countSpecifier: .exactly(1))
        XCTAssertHaveReceived(subject, .doStuffWithString, with: actualString, countSpecifier: .exactly(2))
        XCTAssertHaveNotReceived(subject, .doStuffWithString, with: actualString, countSpecifier: .exactly(3))

        XCTAssertHaveReceived(subject, .doStuffWithString, with: actualString, countSpecifier: .atLeast(1))
        XCTAssertHaveReceived(subject, .doStuffWithString, with: actualString, countSpecifier: .atLeast(2))
        XCTAssertHaveNotReceived(subject, .doStuffWithString, with: actualString, countSpecifier: .atLeast(3))

        XCTAssertHaveNotReceived(subject, .doStuffWithString, with: actualString, countSpecifier: .atMost(1))
        XCTAssertHaveReceived(subject, .doStuffWithString, with: actualString, countSpecifier: .atMost(2))
        XCTAssertHaveReceived(subject, .doStuffWithString, with: actualString, countSpecifier: .atMost(3))
    }

    func test_call_class_function_with_args_count_specifier() {
        let arg = "arg"
        SpyableTestHelper.doClassStuffWith(string: arg)
        SpyableTestHelper.doClassStuffWith(string: "other arg")
        SpyableTestHelper.doClassStuffWith(string: arg)

        XCTAssertHaveNotReceived(SpyableTestHelper.self, .doStuffWithString, with: arg, countSpecifier: .exactly(1))
        XCTAssertHaveReceived(SpyableTestHelper.self, .doStuffWithString, with: arg, countSpecifier: .exactly(2))
        XCTAssertHaveNotReceived(SpyableTestHelper.self, .doStuffWithString, with: arg, countSpecifier: .exactly(3))

        XCTAssertHaveReceived(SpyableTestHelper.self, .doStuffWithString, with: arg, countSpecifier: .atLeast(1))
        XCTAssertHaveReceived(SpyableTestHelper.self, .doStuffWithString, with: arg, countSpecifier: .atLeast(2))
        XCTAssertHaveNotReceived(SpyableTestHelper.self, .doStuffWithString, with: arg, countSpecifier: .atLeast(3))

        XCTAssertHaveNotReceived(SpyableTestHelper.self, .doStuffWithString, with: arg, countSpecifier: .atMost(1))
        XCTAssertHaveReceived(SpyableTestHelper.self, .doStuffWithString, with: arg, countSpecifier: .atMost(2))
        XCTAssertHaveReceived(SpyableTestHelper.self, .doStuffWithString, with: arg, countSpecifier: .atMost(3))
    }

    func test_call_class_function() {
        let actualArgument = "correct string"
        SpyableTestHelper.doClassStuffWith(string: actualArgument)
        XCTAssertTrue(SpyableTestHelper.didCall(.doStuffWithString).success)
        XCTAssertTrue(SpyableTestHelper.didCall(.doStuffWithString, withArguments: [actualArgument]).success)
        XCTAssertTrue(SpyableTestHelper.didCall(.doStuffWithString, countSpecifier: .exactly(1)).success)
        XCTAssertTrue(SpyableTestHelper.didCall(.doStuffWithString, withArguments: [actualArgument], countSpecifier: .exactly(1)).success)
        XCTAssertFalse(SpyableTestHelper.didCall(.doStuff).success)
    }

    func test_result_recordedCallsDescription() {
        XCTAssertEqual(subject.didCall(.doStuff).friendlyDescription, "<>")

        subject.doStuff()
        XCTAssertEqual(subject.didCall(.doStuff).friendlyDescription, "\(SpyableTestHelper.Function.doStuff.rawValue)")

        let firstArg = 1
        let secondArg = 2

        subject.resetCalls()
        subject.doStuffWith(int1: firstArg, int2: secondArg)
        let expectedDescription = "\(SpyableTestHelper.Function.doStuffWithInts.rawValue) with <\(firstArg)>, <\(secondArg)>"
        XCTAssertEqual(subject.didCall(.doStuff).friendlyDescription, expectedDescription)

        subject.resetCalls()
        subject.doStuff()
        subject.doStuffWith(int1: firstArg, int2: secondArg)
        let expectedDescription2 = "\(SpyableTestHelper.Function.doStuff.rawValue); \(SpyableTestHelper.Function.doStuffWithInts.rawValue) with <\(firstArg)>, <\(secondArg)>"
        XCTAssertEqual(subject.didCall(.doStuff).friendlyDescription, expectedDescription2)
    }
}

private final class SpyableTestHelper: Spyable {
    enum ClassFunction: String, StringRepresentable {
        case doStuff = "doClassStuff()"
        case doStuffWithString = "doClassStuffWith(string:)"
    }

    static func doClassStuff() {
        recordCall()
    }

    static func doClassStuffWith(string: String) {
        recordCall(arguments: string)
    }

    enum Function: String, StringRepresentable {
        case ivarProperty
        case doStuff = "doStuff()"
        case doStuffWithString = "doStuffWith(string:)"
        case doStuffWithInts = "doStuffWith(int1:int2:)"
    }

    var ivarProperty: String = "" {
        didSet {
            recordCall(arguments: ivarProperty)
        }
    }

    func doStuff() {
        recordCall()
    }

    func doStuffWith(string: String) {
        recordCall(arguments: string)
    }

    func doStuffWith(int1: Int, int2: Int) {
        recordCall(arguments: int1, int2)
    }
}
