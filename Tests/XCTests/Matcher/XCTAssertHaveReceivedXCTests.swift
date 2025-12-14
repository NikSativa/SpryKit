import Foundation
import SpryKit
import XCTest

final class XCTAssertHaveReceivedXCTests: XCTestCase {
    let actualArgument = "correct arg"
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
