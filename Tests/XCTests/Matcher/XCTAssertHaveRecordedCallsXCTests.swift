import Foundation
import SpryKit
import XCTest

final class XCTAssertHaveRecordedCallsXCTests: XCTestCase {
    override func tearDown() {
        super.tearDown()
        SpyableTestHelper.resetCalls()
    }

    func testHaveRecordedCalls() {
        let subject: SpyableTestHelper = .init()
        XCTAssertHaveNoRecordedCalls(subject)
        subject.doStuff()
        XCTAssertHaveRecordedCalls(subject)

        XCTAssertHaveNoRecordedCalls(SpyableTestHelper.self)
        SpyableTestHelper.doClassStuff()
        XCTAssertHaveRecordedCalls(SpyableTestHelper.self)
    }

    func test_failures_are_reported() {
        let subject = SpyableTestHelper()

        XCTExpectFailure(failingBlock: {
            XCTAssertHaveRecordedCalls(subject)
        }, issueMatcher: { $0.compactDescription.contains("have recorded 0 calls") })

        subject.doStuff()

        XCTExpectFailure(failingBlock: {
            XCTAssertHaveNoRecordedCalls(subject)
        }, issueMatcher: { $0.compactDescription.contains("have recorded 1 call") })

        XCTExpectFailure(failingBlock: {
            XCTAssertHaveRecordedCalls(SpyableTestHelper.self)
        }, issueMatcher: { $0.compactDescription.contains("have recorded 0 calls") })

        SpyableTestHelper.doClassStuff()

        XCTExpectFailure(failingBlock: {
            XCTAssertHaveNoRecordedCalls(SpyableTestHelper.self)
        }, issueMatcher: { $0.compactDescription.contains("have recorded 1 call") })
    }
}

private final class SpyableTestHelper: Spyable {
    enum ClassFunction: String, StringRepresentable {
        case doStuff = "doClassStuff()"
    }

    static func doClassStuff() {
        recordCall()
    }

    enum Function: String, StringRepresentable {
        case doStuff = "doStuff()"
    }

    func doStuff() {
        recordCall()
    }
}
