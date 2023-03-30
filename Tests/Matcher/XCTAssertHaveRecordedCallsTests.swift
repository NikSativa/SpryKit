import Foundation
import NSpry
import XCTest

final class XCTAssertHaveRecordedCallsTests: XCTestCase {
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
}
