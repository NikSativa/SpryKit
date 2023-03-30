import Foundation
import NSpry
import XCTest

final class XCTAssertTests: XCTestCase {
    let actualArgument = "correct arg"
    let subject: SpyableTestHelper = .init()

    override func tearDown() {
        super.tearDown()
        SpyableTestHelper.resetCalls()
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

    func testHaveRecordedCalls() {
        XCTAssertHaveNoRecordedCalls(subject)
        subject.doStuff()
        XCTAssertHaveRecordedCalls(subject)

        XCTAssertHaveNoRecordedCalls(SpyableTestHelper.self)
        SpyableTestHelper.doClassStuff()
        XCTAssertHaveRecordedCalls(SpyableTestHelper.self)
    }
}
