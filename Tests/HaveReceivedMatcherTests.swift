import Foundation
import NSpry
import XCTest

final class HaveReceivedMatcherTests: XCTestCase {
    override func tearDown() {
        super.tearDown()
        SpyableTestHelper.resetCalls()
    }

    func test_have_received_success_result() {
        let subject = SpyableTestHelper()
        let actualArgument = "correct arg"

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
}
