#if canImport(Testing)
import Foundation
import SpryKit
import Testing

private var asyncTestTimeLimit: any SuiteTrait {
    guard #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) else {
        return ConditionTrait.enabled(if: true)
    }

    return TimeLimitTrait.timeLimit(.minutes(1))
}

@Suite("Spryable Async Tests", .serialized, asyncTestTimeLimit)
final class SpryableAsyncTests {
    private let subject: SpryableAsyncTestClass = .init()

    deinit {
        SpryableAsyncTestClass.resetCallsAndStubs()
    }

    @Test("Async functions answer immediate stubs")
    func async_functions_answer_immediate_stubs() async throws {
        subject.stub(.loadValue).andReturn("loaded")
        subject.stub(.count).andDo { _ in
            return 3
        }
        subject.stub(.remoteName).andThrow(SpryableTestError.notFound)

        #expect(try await subject.loadValue() == "loaded")
        #expect(await subject.count() == 3)
        await #expect(throws: SpryableTestError.notFound) {
            try await subject.remoteName
        }
        #expect(subject.didCall(.remoteName).isSuccess)
    }

    @Test("A call recorded before the wait ends it at once")
    func a_call_recorded_before_the_wait_ends_it_at_once() async throws {
        subject.stub(.loadValue).andReturn("loaded")
        _ = try await subject.loadValue()

        try await subject.waitForCall(.loadValue)
    }

    @Test("A call made after the wait started ends it")
    func a_call_made_after_the_wait_started_ends_it() async throws {
        subject.stub(.loadValue).andReturn("loaded")
        let waiting = Task { [subject] in
            try await subject.waitForCall(.loadValue)
        }

        #expect(try await subject.loadValue() == "loaded")
        try await waiting.value
    }

    @Test("Calls with other arguments do not end the wait")
    func calls_with_other_arguments_do_not_end_the_wait() async throws {
        subject.stub(.loadValueWithKey).andReturn("loaded")
        _ = try await subject.loadValue(key: "other")
        let waiting = Task { [subject] in
            try await subject.waitForCall(.loadValueWithKey, withArguments: ["expected"])
        }

        _ = try await subject.loadValue(key: "other")
        waiting.cancel()

        await #expect(throws: CancellationError.self) {
            try await waiting.value
        }
    }

    @Test("A wait for several calls counts every matching call")
    func a_wait_for_several_calls_counts_every_matching_call() async throws {
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

        await #expect(throws: CancellationError.self) {
            try await waitingForThree.value
        }
    }

    @Test("A class function can be awaited and answered")
    func a_class_function_can_be_awaited_and_answered() async throws {
        let response = SpryableAsyncTestClass.stub(.loadShared).andWaitForResponse()
        let loading = Task {
            return try await SpryableAsyncTestClass.loadShared()
        }

        try await SpryableAsyncTestClass.waitForCall(.loadShared)
        response.respond(with: "shared")

        #expect(try await loading.value == "shared")
    }

    @Test("A waiting call returns the response")
    func a_waiting_call_returns_the_response() async throws {
        let response = subject.stub(.loadValue).andWaitForResponse()
        let loading = Task { [subject] in
            return try await subject.loadValue()
        }

        try await subject.waitForCall(.loadValue)
        response.respond(with: "loaded")

        #expect(try await loading.value == "loaded")
    }

    @Test("A response given in advance answers the next call")
    func a_response_given_in_advance_answers_the_next_call() async throws {
        let response = subject.stub(.loadValue).andWaitForResponse()
        response.respond(with: "prepared")

        #expect(try await subject.loadValue() == "prepared")
    }

    @Test("Responses answer calls in the order the calls arrived")
    func responses_answer_calls_in_the_order_the_calls_arrived() async throws {
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

        #expect(try await first.value == "1")
        #expect(try await second.value == "2")
    }

    @Test("A waiting call throws the response error")
    func a_waiting_call_throws_the_response_error() async throws {
        let response = subject.stub(.loadValue).andWaitForResponse()
        let loading = Task { [subject] in
            return try await subject.loadValue()
        }

        try await subject.waitForCall(.loadValue)
        response.respond(throwing: SpryableTestError.notFound)

        await #expect(throws: SpryableTestError.notFound) {
            try await loading.value
        }
    }

    @Test("A waiting Void call finishes on respond()")
    func a_waiting_void_call_finishes_on_respond() async throws {
        let response = subject.stub(.pauseWithSeconds).andWaitForResponse()
        let pausing = Task { [subject] in
            try await subject.pause(seconds: 3)
        }

        try await subject.waitForCall(.pauseWithSeconds, withArguments: [3])
        response.respond()

        try await pausing.value
    }

    @Test("A waiting stub matches and captures arguments before it is answered")
    func a_waiting_stub_matches_and_captures_arguments_before_it_is_answered() async throws {
        let captor = Argument.captor()
        let response = subject.stub(.loadValueWithKey).with(captor).andWaitForResponse()
        let loading = Task { [subject] in
            return try await subject.loadValue(key: "user")
        }

        try await subject.waitForCall(.loadValueWithKey)
        #expect(captor.getValue(as: String.self) == "user")
        response.respond(with: "loaded")

        #expect(try await loading.value == "loaded")
    }

    @Test("Cancelling a waiting call throws CancellationError and keeps later responses")
    func cancelling_a_waiting_call_throws_CancellationError_and_keeps_later_responses() async throws {
        let response = subject.stub(.loadValue).andWaitForResponse()
        let cancelled = Task { [subject] in
            return try await subject.loadValue()
        }

        try await subject.waitForCall(.loadValue)
        cancelled.cancel()
        await #expect(throws: CancellationError.self) {
            try await cancelled.value
        }

        response.respond(with: "next")
        #expect(try await subject.loadValue() == "next")
    }

    @Test("A cancelled non-throwing call keeps waiting for its response")
    func a_cancelled_non_throwing_call_keeps_waiting_for_its_response() async throws {
        let response = subject.stub(.count).andWaitForResponse()
        let counting = Task { [subject] in
            return await subject.count()
        }

        try await subject.waitForCall(.count)
        counting.cancel()
        response.respond(with: 7)

        #expect(await counting.value == 7)
    }

    @Test("A synchronous function cannot wait for a response")
    func a_synchronous_function_cannot_wait_for_a_response() {
        _ = subject.stub(.cachedValue).andWaitForResponse()

        expectThrowsAssertion { [subject] in
            return subject.cachedValue()
        }
    }

    @Test("The value wins the race when it arrives before the deadline")
    func the_value_wins_the_race_when_it_arrives_before_the_deadline() async throws {
        let value = subject.stub(.loadValue).andWaitForResponse()
        _ = subject.stub(.pauseWithSeconds).andWaitForResponse()
        let loader = DeadlineLoader(source: subject)
        let loading = Task {
            return try await loader.load(within: 3)
        }

        try await subject.waitForCall(.loadValue)
        try await subject.waitForCall(.pauseWithSeconds, withArguments: [3])
        value.respond(with: "loaded")

        #expect(try await loading.value == "loaded")
    }

    @Test("The deadline wins the race when it passes before the value arrives")
    func the_deadline_wins_the_race_when_it_passes_before_the_value_arrives() async throws {
        _ = subject.stub(.loadValue).andWaitForResponse()
        let deadline = subject.stub(.pauseWithSeconds).andWaitForResponse()
        let loader = DeadlineLoader(source: subject)
        let loading = Task {
            return try await loader.load(within: 3)
        }

        try await subject.waitForCall(.loadValue)
        try await subject.waitForCall(.pauseWithSeconds)
        deadline.respond()

        await #expect(throws: DeadlineLoader.Error.timedOut) {
            try await loading.value
        }
    }

    @Test("Cancelling the caller ends both waiting calls")
    func cancelling_the_caller_ends_both_waiting_calls() async throws {
        _ = subject.stub(.loadValue).andWaitForResponse()
        _ = subject.stub(.pauseWithSeconds).andWaitForResponse()
        let loader = DeadlineLoader(source: subject)
        let loading = Task {
            return try await loader.load(within: 3)
        }

        try await subject.waitForCall(.loadValue)
        try await subject.waitForCall(.pauseWithSeconds)
        loading.cancel()

        await #expect(throws: CancellationError.self) {
            try await loading.value
        }
    }
}
#endif // canImport(Testing)
