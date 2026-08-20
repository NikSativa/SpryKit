import Foundation
import SpryKit
import XCTest

final class XCTAssertHaveReceivedXCTests: XCTestCase {
    private let actualArgument = "correct arg"
    private let subject: SpyableTestHelper = .init()

    override func tearDown() {
        super.tearDown()
        subject.resetCalls()
        SpyableTestHelper.resetCalls()
    }

    func test_have_received_success_result() {
        // instance
        subject.doStuffWith(string: actualArgument)

        XCTAssertHaveReceived(subject, .doStuffWithString)
        XCTAssertHaveReceived(subject, .doStuffWithString, with: actualArgument)
        XCTAssertHaveReceived(subject, .doStuffWithString, countSpecifier: .exactly(1))
        XCTAssertHaveReceived(subject, .doStuffWithString, with: actualArgument, countSpecifier: .exactly(1))

        XCTAssertHaveNotReceived(subject, .doStuff)
        XCTAssertHaveNotReceived(subject, .doStuffWithInts)

        // class
        SpyableTestHelper.doClassStuffWith(string: actualArgument)
        XCTAssertHaveReceived(SpyableTestHelper.self, .doStuffWithString)
        XCTAssertHaveReceived(SpyableTestHelper.self, .doStuffWithString, with: actualArgument)
        XCTAssertHaveReceived(SpyableTestHelper.self, .doStuffWithString, countSpecifier: .exactly(1))
        XCTAssertHaveReceived(SpyableTestHelper.self, .doStuffWithString, with: actualArgument, countSpecifier: .exactly(1))

        XCTAssertHaveNotReceived(SpyableTestHelper.self, .doStuff)
    }

    func testHaveReceived() {
        subject.doStuff()

        XCTAssertHaveReceived(subject, .doStuff)
        XCTAssertHaveReceived(subject, .doStuff, countSpecifier: .exactly(1))

        XCTAssertHaveNotReceived(subject, .doStuffWithString)
        XCTAssertHaveNotReceived(subject, .doStuffWithInts)
    }

    func testHaveReceivedWithArgument() {
        subject.doStuffWith(string: actualArgument)

        XCTAssertHaveReceived(subject, .doStuffWithString)
        XCTAssertHaveReceived(subject, .doStuffWithString, with: actualArgument)
        XCTAssertHaveReceived(subject, .doStuffWithString, countSpecifier: .exactly(1))
        XCTAssertHaveReceived(subject, .doStuffWithString, with: actualArgument, countSpecifier: .exactly(1))

        XCTAssertHaveNotReceived(subject, .doStuff)
        XCTAssertHaveNotReceived(subject, .doStuffWithInts)
    }

    func testHaveReceivedWith2Arguments() {
        subject.doStuffWith(int1: 1, int2: 2)

        XCTAssertHaveReceived(subject, .doStuffWithInts)
        XCTAssertHaveReceived(subject, .doStuffWithInts, with: 1, 2)
        XCTAssertHaveReceived(subject, .doStuffWithInts, countSpecifier: .exactly(1))
        XCTAssertHaveReceived(subject, .doStuffWithInts, with: 1, 2, countSpecifier: .exactly(1))

        XCTAssertHaveNotReceived(subject, .doStuff)
        XCTAssertHaveNotReceived(subject, .doStuffWithString)
    }

    func test_nil_spyable_explains_itself() {
        let missing: SpyableTestHelper? = nil

        XCTExpectFailure("nil spyable is reported with an explanation", failingBlock: {
            XCTAssertHaveReceived(missing, .doStuff)
        }, issueMatcher: { issue in
            issue.compactDescription.contains("but spyable is nil")
        })

        XCTExpectFailure("nil spyable is reported with an explanation", failingBlock: {
            XCTAssertHaveNotReceived(missing, .doStuff)
        }, issueMatcher: { issue in
            issue.compactDescription.contains("but spyable is nil")
        })
    }

    func test_count_specifiers_shape_the_report() {
        subject.doStuff()
        subject.doStuff()

        XCTAssertHaveReceived(subject, .doStuff, countSpecifier: .exactly(2))
        XCTAssertHaveReceived(subject, .doStuff, countSpecifier: .atLeast(2))
        XCTAssertHaveReceived(subject, .doStuff, countSpecifier: .atMost(2))
        XCTAssertHaveNotReceived(subject, .doStuff, countSpecifier: .exactly(3))

        XCTExpectFailure(failingBlock: {
            XCTAssertHaveReceived(self.subject, .doStuff, countSpecifier: .exactly(3))
        }, issueMatcher: { $0.compactDescription.contains("exactly 3 times") })

        XCTExpectFailure(failingBlock: {
            XCTAssertHaveReceived(self.subject, .doStuff, countSpecifier: .atLeast(3))
        }, issueMatcher: { $0.compactDescription.contains("at least 3 times") })

        XCTExpectFailure(failingBlock: {
            XCTAssertHaveReceived(self.subject, .doStuff, countSpecifier: .atMost(1))
        }, issueMatcher: { $0.compactDescription.contains("at most 1 time") })
    }

    func test_nil_spyable_reports_each_count_specifier() {
        let missing: SpyableTestHelper? = nil

        XCTExpectFailure(failingBlock: {
            XCTAssertHaveReceived(missing, .doStuffWithString, with: "x", countSpecifier: .exactly(1))
        }, issueMatcher: { $0.compactDescription.contains("with arguments") && $0.compactDescription.contains("'count' times") })

        XCTExpectFailure(failingBlock: {
            XCTAssertHaveReceived(missing, .doStuff, countSpecifier: .atLeast(2))
        }, issueMatcher: { $0.compactDescription.contains("at least 'count' times") })

        XCTExpectFailure(failingBlock: {
            XCTAssertHaveReceived(missing, .doStuff, countSpecifier: .atMost(2))
        }, issueMatcher: { $0.compactDescription.contains("at most 'count' times") })

        XCTExpectFailure(failingBlock: {
            XCTAssertHaveNotReceived(missing, .doStuffWithString, with: "x")
        }, issueMatcher: { _ in true })

        XCTExpectFailure(failingBlock: {
            XCTAssertHaveReceived(SpyableTestHelper.Type?.none, .doStuff)
        }, issueMatcher: { _ in true })

        XCTExpectFailure(failingBlock: {
            XCTAssertHaveNotReceived(SpyableTestHelper.Type?.none, .doStuff, with: "x")
        }, issueMatcher: { _ in true })
    }

    func test_class_count_specifiers() {
        SpyableTestHelper.doClassStuff()

        XCTAssertHaveReceived(SpyableTestHelper.self, .doStuff, countSpecifier: .exactly(1))
        XCTAssertHaveNotReceived(SpyableTestHelper.self, .doStuff, countSpecifier: .exactly(2))

        XCTExpectFailure(failingBlock: {
            XCTAssertHaveReceived(SpyableTestHelper.self, .doStuffWithString, with: "x", countSpecifier: .exactly(1))
        }, issueMatcher: { _ in true })

        XCTExpectFailure(failingBlock: {
            XCTAssertHaveNotReceived(SpyableTestHelper.self, .doStuff)
        }, issueMatcher: { _ in true })
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
        case doStuff = "doStuff()"
        case doStuffWithString = "doStuffWith(string:)"
        case doStuffWithInts = "doStuffWith(int1:int2:)"
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
