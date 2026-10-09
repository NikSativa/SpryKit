import Foundation
import Threading

/// Answers the calls of a stub registered with `andWaitForResponse()`.
///
/// A call to such a stub waits until the test answers it. Every response answers exactly one call: the
/// oldest call that is still waiting, or the next call to arrive when none is waiting. Responses given
/// in advance are kept in order, so a test can prepare them before the calls happen.
///
/// A waiting call of a throwing function ends with `CancellationError` when its task is cancelled. A
/// non-throwing function has no way to report cancellation, so its call keeps waiting until the test
/// answers it.
///
/// ## Example ##
/// ```swift
/// let response = service.stub(.loadValue).andWaitForResponse()
/// async let value = subject.load()
///
/// try await service.waitForCall(.loadValue)
/// response.respond(with: "loaded value")
///
/// #expect(try await value == "loaded value")
/// ```
public final class StubResponder: @unchecked Sendable {
    private struct Response: @unchecked Sendable {
        let result: Result<Any?, any Error>
    }

    private struct PendingCall {
        let id: Int
        var response: Response?
        var continuation: CheckedContinuation<Response, Never>?
    }

    private struct State {
        var unclaimedResponses: [Response] = []
        var pendingCalls: [PendingCall] = []
        var lastCallID = 0
    }

    private let state = AtomicValue(wrappedValue: State())

    /// Answers the next call with a value.
    ///
    /// - Important: The value must have the return type of the stubbed function, otherwise the call traps.
    ///
    /// - Parameter value: The value the stubbed function returns.
    public func respond(with value: Any?) {
        deliver(Response(result: .success(value)))
    }

    /// Answers the next call of a function that returns `Void`.
    public func respond() {
        deliver(Response(result: .success(())))
    }

    /// Answers the next call by throwing an error.
    ///
    /// - Important: Only answer a throwing function this way. A non-throwing function traps, as it does with `andThrow()`.
    ///
    /// - Parameter error: The error the stubbed function throws.
    public func respond(throwing error: any Error) {
        deliver(Response(result: .failure(error)))
    }

    func reserveCall() -> Int {
        return state.syncUnchecked { state in
            state.lastCallID &+= 1
            let response = state.unclaimedResponses.isEmpty ? nil : state.unclaimedResponses.removeFirst()
            state.pendingCalls.append(PendingCall(id: state.lastCallID, response: response))
            return state.lastCallID
        }
    }

    func response(toCall callID: Int, isCancellable: Bool) async throws -> Any? {
        let response: Response
        if isCancellable {
            response = await withTaskCancellationHandler {
                return await waitForResponse(toCall: callID, isCancellable: true)
            } onCancel: {
                cancelCall(callID)
            }
        } else {
            response = await waitForResponse(toCall: callID, isCancellable: false)
        }

        return try response.result.get()
    }

    private func waitForResponse(toCall callID: Int, isCancellable: Bool) async -> Response {
        return await withCheckedContinuation { continuation in
            let readyResponse: Response? = state.syncUnchecked { state in
                guard let index = state.pendingCalls.firstIndex(where: { $0.id == callID }) else {
                    return Response(result: .failure(CancellationError()))
                }

                if let response = state.pendingCalls[index].response {
                    state.pendingCalls.remove(at: index)
                    return response
                }

                if isCancellable, Task.isCancelled {
                    state.pendingCalls.remove(at: index)
                    return Response(result: .failure(CancellationError()))
                }

                state.pendingCalls[index].continuation = continuation
                return nil
            }

            if let readyResponse {
                continuation.resume(returning: readyResponse)
            }
        }
    }

    private func cancelCall(_ callID: Int) {
        let continuation = state.syncUnchecked { state -> CheckedContinuation<Response, Never>? in
            guard let index = state.pendingCalls.firstIndex(where: { $0.id == callID }),
                  state.pendingCalls[index].response == nil else {
                return nil
            }

            return state.pendingCalls.remove(at: index).continuation
        }

        continuation?.resume(returning: Response(result: .failure(CancellationError())))
    }

    private func deliver(_ response: Response) {
        let continuation = state.syncUnchecked { state -> CheckedContinuation<Response, Never>? in
            guard let index = state.pendingCalls.firstIndex(where: { $0.response == nil }) else {
                state.unclaimedResponses.append(response)
                return nil
            }

            guard let continuation = state.pendingCalls[index].continuation else {
                state.pendingCalls[index].response = response
                return nil
            }

            state.pendingCalls.remove(at: index)
            return continuation
        }

        continuation?.resume(returning: response)
    }
}
