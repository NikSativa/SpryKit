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
