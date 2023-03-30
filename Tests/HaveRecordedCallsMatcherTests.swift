import Foundation
import NSpry
import XCTest

final class HaveRecordedCallsMatcherTests: XCTestCase {
    override func tearDown() {
        super.tearDown()
        SpyableTestHelper.resetCalls()
    }

    func test_at_least_one_call_has_been_made() {
        let subject: SpyableTestHelper = .init()

        XCTAssertHaveNoRecordedCalls(subject)
        XCTAssertHaveNoRecordedCalls(SpyableTestHelper.self)

        subject.doStuff()
        XCTAssertHaveRecordedCalls(subject)

        SpyableTestHelper.doClassStuff()
        XCTAssertHaveRecordedCalls(SpyableTestHelper.self)

        subject.resetCalls()
        XCTAssertHaveNoRecordedCalls(subject)

        SpyableTestHelper.resetCalls()
        XCTAssertHaveNoRecordedCalls(SpyableTestHelper.self)
    }
}
