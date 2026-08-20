import Foundation
import SpryKit
import XCTest

final class ArgumentCaptorXCTests: XCTestCase {
    func test_captures_nothing_before_the_first_matching_call() {
        let subject = Argument.captor()

        XCTAssertFalse(subject.isType(String.self))
        XCTAssertThrowsAssertion {
            let _: String = subject.getValue()
        }
    }

    func test_subscript_and_getValue_address_the_same_capture() {
        let fake = ArgumentCaptorTestHelper()
        let subject = Argument.captor()
        fake.stub(.takeWithValue).with(subject).andReturn()

        fake.take(value: "first")
        fake.take(value: "second")

        XCTAssertEqual(subject.getValue(as: String.self), "first")
        XCTAssertEqual(subject.getValue(at: 1, as: String.self), "second")

        let byIndex: String = subject[1]
        XCTAssertEqual(byIndex, "second")
    }

    func test_isType_inspects_a_capture_without_extracting_it() {
        let fake = ArgumentCaptorTestHelper()
        let subject = Argument.captor()
        fake.stub(.takeWithValue).with(subject).andReturn()

        fake.take(value: "text")

        XCTAssertTrue(subject.isType(String.self))
        XCTAssertFalse(subject.isType(Int.self))
        XCTAssertFalse(subject.isType(String.self, at: 1))
        XCTAssertFalse(subject.isType(String.self, at: -1))
    }

    func test_out_of_bounds_index_traps() {
        let fake = ArgumentCaptorTestHelper()
        let subject = Argument.captor()
        fake.stub(.takeWithValue).with(subject).andReturn()
        fake.take(value: "text")

        XCTAssertThrowsAssertion {
            let _: String = subject.getValue(at: 1)
        }

        XCTAssertThrowsAssertion {
            let _: String = subject.getValue(at: -1)
        }
    }

    func test_wrong_requested_type_traps() {
        let fake = ArgumentCaptorTestHelper()
        let subject = Argument.captor()
        fake.stub(.takeWithValue).with(subject).andReturn()
        fake.take(value: "text")

        XCTAssertThrowsAssertion {
            let _: Int = subject.getValue()
        }
    }

    func test_stays_usable_after_a_caught_trap() {
        let fake = ArgumentCaptorTestHelper()
        let subject = Argument.captor()
        fake.stub(.takeWithValue).with(subject).andReturn()
        fake.take(value: "text")

        XCTAssertThrowsAssertion {
            let _: Int = subject.getValue()
        }

        XCTAssertTrue(subject.isType(String.self))
        XCTAssertEqual(subject.getValue(as: String.self), "text")
    }

    func test_a_captor_matches_any_argument() {
        let fake = ArgumentCaptorTestHelper()
        let subject = Argument.captor()
        fake.stub(.takeWithValue).with(subject).andReturn()

        fake.take(value: 42)
        fake.take(value: "text")

        XCTAssertEqual(subject.getValue(as: Int.self), 42)
        XCTAssertEqual(subject.getValue(at: 1, as: String.self), "text")
    }
}

private final class ArgumentCaptorTestHelper: Spryable {
    enum ClassFunction: String, StringRepresentable {
        case _unknown_
    }

    enum Function: String, StringRepresentable {
        case takeWithValue = "take(value:)"
    }

    func take(value: Any) {
        return spryify(arguments: value)
    }
}
