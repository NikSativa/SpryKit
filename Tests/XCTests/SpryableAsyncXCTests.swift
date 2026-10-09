import Foundation
import SpryKit
import XCTest

final class SpryableAsyncXCTests: XCTestCase {
    private let subject: SpryableAsyncTestClass = .init()

    override func tearDown() {
        super.tearDown()
        subject.resetCallsAndStubs()
        SpryableAsyncTestClass.resetCallsAndStubs()
    }

    func test_async_functions_answer_immediate_stubs() async throws {
        subject.stub(.loadValue).andReturn("loaded")
        subject.stub(.count).andDo { _ in
            return 3
        }
        subject.stub(.remoteName).andThrow(SpryableTestError.notFound)

        let value = try await subject.loadValue()
        let count = await subject.count()

        XCTAssertEqual(value, "loaded")
        XCTAssertEqual(count, 3)
        await assertThrows(SpryableTestError.notFound) { [subject] in
            _ = try await subject.remoteName
        }
        XCTAssertHaveReceived(subject, .remoteName)
    }

    func test_a_call_recorded_before_the_wait_ends_it_at_once() async throws {
        subject.stub(.loadValue).andReturn("loaded")
        _ = try await subject.loadValue()

        try await subject.waitForCall(.loadValue)
    }

    func test_a_call_made_after_the_wait_started_ends_it() async throws {
        subject.stub(.loadValue).andReturn("loaded")
        let waiting = Task { [subject] in
            try await subject.waitForCall(.loadValue)
        }

        let value = try await subject.loadValue()
        try await waiting.value

        XCTAssertEqual(value, "loaded")
    }

    func test_calls_with_other_arguments_do_not_end_the_wait() async throws {
        subject.stub(.loadValueWithKey).andReturn("loaded")
        _ = try await subject.loadValue(key: "other")
        let waiting = Task { [subject] in
            try await subject.waitForCall(.loadValueWithKey, withArguments: ["expected"])
        }

        _ = try await subject.loadValue(key: "other")
        waiting.cancel()

        await assertCancellation {
            try await waiting.value
        }
    }

    func test_a_wait_for_several_calls_counts_every_matching_call() async throws {
        subject.stub(.loadValue).andReturn("loaded")
        _ = try await subject.loadValue()
        let waitingForThree = Task { [subject] in
            try await subject.waitForCall(.loadValue, times: 3)
        }
        let waitingForTwo = Task { [subject] in
            try await subject.waitForCall(.loadValue, times: 2)
        }

        _ = try await subject.loadValue()
        try await waitingForTwo.value
        waitingForThree.cancel()

        await assertCancellation {
            try await waitingForThree.value
        }
    }

    func test_a_class_function_can_be_awaited_and_answered() async throws {
        let response = SpryableAsyncTestClass.stub(.loadShared).andWaitForResponse()
        let loading = Task {
            return try await SpryableAsyncTestClass.loadShared()
        }

        try await SpryableAsyncTestClass.waitForCall(.loadShared)
        response.respond(with: "shared")
        let value = try await loading.value

        XCTAssertEqual(value, "shared")
    }

    func test_a_waiting_call_returns_the_response() async throws {
        let response = subject.stub(.loadValue).andWaitForResponse()
        let loading = Task { [subject] in
            return try await subject.loadValue()
        }

        try await subject.waitForCall(.loadValue)
        response.respond(with: "loaded")
        let value = try await loading.value

        XCTAssertEqual(value, "loaded")
    }

    func test_a_response_given_in_advance_answers_the_next_call() async throws {
        let response = subject.stub(.loadValue).andWaitForResponse()
        response.respond(with: "prepared")

        let value = try await subject.loadValue()

        XCTAssertEqual(value, "prepared")
    }

    func test_responses_answer_calls_in_the_order_the_calls_arrived() async throws {
        let response = subject.stub(.loadValueWithKey).andWaitForResponse()
        let first = Task { [subject] in
            return try await subject.loadValue(key: "first")
        }
        try await subject.waitForCall(.loadValueWithKey)

        let second = Task { [subject] in
            return try await subject.loadValue(key: "second")
        }
        try await subject.waitForCall(.loadValueWithKey, times: 2)

        response.respond(with: "1")
        response.respond(with: "2")
        let firstValue = try await first.value
        let secondValue = try await second.value

        XCTAssertEqual(firstValue, "1")
        XCTAssertEqual(secondValue, "2")
    }

    func test_a_waiting_call_throws_the_response_error() async throws {
        let response = subject.stub(.loadValue).andWaitForResponse()
        let loading = Task { [subject] in
            return try await subject.loadValue()
        }

        try await subject.waitForCall(.loadValue)
        response.respond(throwing: SpryableTestError.notFound)

        await assertThrows(SpryableTestError.notFound) {
            _ = try await loading.value
        }
    }

    func test_a_waiting_void_call_finishes_on_respond() async throws {
        let response = subject.stub(.pauseWithSeconds).andWaitForResponse()
        let pausing = Task { [subject] in
            try await subject.pause(seconds: 3)
        }

        try await subject.waitForCall(.pauseWithSeconds, withArguments: [3])
        response.respond()

        try await pausing.value
    }

    func test_a_waiting_stub_matches_and_captures_arguments_before_it_is_answered() async throws {
        let captor = Argument.captor()
        let response = subject.stub(.loadValueWithKey).with(captor).andWaitForResponse()
        let loading = Task { [subject] in
            return try await subject.loadValue(key: "user")
        }

        try await subject.waitForCall(.loadValueWithKey)
        XCTAssertEqual(captor.getValue(as: String.self), "user")
        response.respond(with: "loaded")
        let value = try await loading.value

        XCTAssertEqual(value, "loaded")
    }

    func test_cancelling_a_waiting_call_throws_CancellationError_and_keeps_later_responses() async throws {
        let response = subject.stub(.loadValue).andWaitForResponse()
        let cancelled = Task { [subject] in
            return try await subject.loadValue()
        }

        try await subject.waitForCall(.loadValue)
        cancelled.cancel()
        await assertCancellation {
            _ = try await cancelled.value
        }

        response.respond(with: "next")
        let value = try await subject.loadValue()

        XCTAssertEqual(value, "next")
    }

    func test_a_cancelled_non_throwing_call_keeps_waiting_for_its_response() async throws {
        let response = subject.stub(.count).andWaitForResponse()
        let counting = Task { [subject] in
            return await subject.count()
        }

        try await subject.waitForCall(.count)
        counting.cancel()
        response.respond(with: 7)
        let count = await counting.value

        XCTAssertEqual(count, 7)
    }

    func test_a_synchronous_function_cannot_wait_for_a_response() {
        _ = subject.stub(.cachedValue).andWaitForResponse()

        XCTAssertThrowsAssertion { [subject] in
            return subject.cachedValue()
        }
    }

    func test_the_value_wins_the_race_when_it_arrives_before_the_deadline() async throws {
        let value = subject.stub(.loadValue).andWaitForResponse()
        _ = subject.stub(.pauseWithSeconds).andWaitForResponse()
        let loader = DeadlineLoader(source: subject)
        let loading = Task {
            return try await loader.load(within: 3)
        }

        try await subject.waitForCall(.loadValue)
        try await subject.waitForCall(.pauseWithSeconds, withArguments: [3])
        value.respond(with: "loaded")
        let loaded = try await loading.value

        XCTAssertEqual(loaded, "loaded")
    }

    func test_the_deadline_wins_the_race_when_it_passes_before_the_value_arrives() async throws {
        _ = subject.stub(.loadValue).andWaitForResponse()
        let deadline = subject.stub(.pauseWithSeconds).andWaitForResponse()
        let loader = DeadlineLoader(source: subject)
        let loading = Task {
            return try await loader.load(within: 3)
        }

        try await subject.waitForCall(.loadValue)
        try await subject.waitForCall(.pauseWithSeconds)
        deadline.respond()

        await assertThrows(DeadlineLoader.Error.timedOut) {
            _ = try await loading.value
        }
    }

    func test_cancelling_the_caller_ends_both_waiting_calls() async throws {
        _ = subject.stub(.loadValue).andWaitForResponse()
        _ = subject.stub(.pauseWithSeconds).andWaitForResponse()
        let loader = DeadlineLoader(source: subject)
        let loading = Task {
            return try await loader.load(within: 3)
        }

        try await subject.waitForCall(.loadValue)
        try await subject.waitForCall(.pauseWithSeconds)
        loading.cancel()

        await assertCancellation {
            _ = try await loading.value
        }
    }

    private func assertThrows<E: Error & Equatable>(_ expected: E, file: StaticString = #filePath, line: UInt = #line, _ work: () async throws -> Void) async {
        do {
            try await work()
            XCTFail("Expected \(expected) to be thrown", file: file, line: line)
        } catch {
            XCTAssertEqual(error as? E, expected, file: file, line: line)
        }
    }

    private func assertCancellation(file: StaticString = #filePath, line: UInt = #line, _ work: () async throws -> Void) async {
        do {
            try await work()
            XCTFail("Expected CancellationError to be thrown", file: file, line: line)
        } catch {
            XCTAssertTrue(error is CancellationError, "Unexpected error: \(error)", file: file, line: line)
        }
    }
}
