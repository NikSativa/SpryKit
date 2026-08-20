#if canImport(Testing)
import Foundation
import SpryKit
import Testing

@Suite("ArgumentCaptor Tests", .serialized)
struct ArgumentCaptorTests {
    @Test("Captures nothing before the first matching call")
    func captures_nothing_before_the_first_matching_call() {
        let subject = Argument.captor()

        #expect(!subject.isType(String.self))
        expectThrowsAssertion {
            let _: String = subject.getValue()
        }
    }

    @Test("Subscript and getValue address the same capture")
    func subscript_and_getValue_address_the_same_capture() {
        let fake = ArgumentCaptorTestHelper()
        let subject = Argument.captor()
        fake.stub(.takeWithValue).with(subject).andReturn()

        fake.take(value: "first")
        fake.take(value: "second")

        #expect(subject.getValue(as: String.self) == "first")
        #expect(subject.getValue(at: 1, as: String.self) == "second")

        let byIndex: String = subject[1]
        #expect(byIndex == "second")
    }

    @Test("isType inspects a capture without extracting it")
    func isType_inspects_a_capture_without_extracting_it() {
        let fake = ArgumentCaptorTestHelper()
        let subject = Argument.captor()
        fake.stub(.takeWithValue).with(subject).andReturn()

        fake.take(value: "text")

        #expect(subject.isType(String.self))
        #expect(!subject.isType(Int.self))
        #expect(!subject.isType(String.self, at: 1))
        #expect(!subject.isType(String.self, at: -1))
    }

    @Test("Out of bounds index traps")
    func out_of_bounds_index_traps() {
        let fake = ArgumentCaptorTestHelper()
        let subject = Argument.captor()
        fake.stub(.takeWithValue).with(subject).andReturn()
        fake.take(value: "text")

        expectThrowsAssertion {
            let _: String = subject.getValue(at: 1)
        }

        expectThrowsAssertion {
            let _: String = subject.getValue(at: -1)
        }
    }

    @Test("Wrong requested type traps")
    func wrong_requested_type_traps() {
        let fake = ArgumentCaptorTestHelper()
        let subject = Argument.captor()
        fake.stub(.takeWithValue).with(subject).andReturn()
        fake.take(value: "text")

        expectThrowsAssertion {
            let _: Int = subject.getValue()
        }
    }

    @Test("Stays usable after a caught trap")
    func stays_usable_after_a_caught_trap() {
        let fake = ArgumentCaptorTestHelper()
        let subject = Argument.captor()
        fake.stub(.takeWithValue).with(subject).andReturn()
        fake.take(value: "text")

        expectThrowsAssertion {
            let _: Int = subject.getValue()
        }

        #expect(subject.isType(String.self))
        #expect(subject.getValue(as: String.self) == "text")
    }

    @Test("A captor matches any argument")
    func a_captor_matches_any_argument() {
        let fake = ArgumentCaptorTestHelper()
        let subject = Argument.captor()
        fake.stub(.takeWithValue).with(subject).andReturn()

        fake.take(value: 42)
        fake.take(value: "text")

        #expect(subject.getValue(as: Int.self) == 42)
        #expect(subject.getValue(at: 1, as: String.self) == "text")
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
#endif // canImport(Testing)
