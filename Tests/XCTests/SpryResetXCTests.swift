import Foundation
import SpryKit
import XCTest

final class SpryResetXCTests: XCTestCase {
    override func tearDown() {
        super.tearDown()
        Spry.resetAll()
    }

    func test_resetAll_clears_instance_state() {
        let fake = ResetTestHelper()
        fake.stub(.ping).andReturn("stubbed")
        _ = fake.ping()

        XCTAssertHaveRecordedCalls(fake)

        Spry.resetAll()

        XCTAssertHaveNoRecordedCalls(fake)
        XCTAssertThrowsAssertion {
            _ = fake.ping()
        }
    }

    func test_resetAll_clears_class_state() {
        ResetTestHelper.stub(.classPing).andReturn("stubbed")
        _ = ResetTestHelper.classPing()

        XCTAssertHaveRecordedCalls(ResetTestHelper.self)

        Spry.resetAll()

        XCTAssertHaveNoRecordedCalls(ResetTestHelper.self)
        XCTAssertThrowsAssertion {
            _ = ResetTestHelper.classPing()
        }
    }

    func test_resetAll_clears_every_fake_at_once() {
        let first = ResetTestHelper()
        let second = ResetTestHelper()
        first.stub(.ping).andReturn("a")
        second.stub(.ping).andReturn("b")
        _ = first.ping()
        _ = second.ping()
        ResetTestHelper.stub(.classPing).andReturn("c")
        _ = ResetTestHelper.classPing()

        Spry.resetAll()

        XCTAssertHaveNoRecordedCalls(first)
        XCTAssertHaveNoRecordedCalls(second)
        XCTAssertHaveNoRecordedCalls(ResetTestHelper.self)
    }

    func test_resetAll_is_safe_when_nothing_was_registered() {
        Spry.resetAll()
        Spry.resetAll()
    }
}

private final class ResetTestHelper: Spryable {
    enum ClassFunction: String, StringRepresentable {
        case classPing = "classPing()"
    }

    enum Function: String, StringRepresentable {
        case ping = "ping()"
    }

    func ping() -> String {
        return spryify()
    }

    static func classPing() -> String {
        return spryify()
    }
}
