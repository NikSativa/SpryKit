import Foundation
import Threading

final class AwaitableCounter: @unchecked Sendable {
    private struct State {
        var value = 0
        var waiters: [Int: CheckedContinuation<Void, any Error>] = [:]
        var lastWaiterID = 0
    }

    private let state = AtomicValue(wrappedValue: State())

    var value: Int {
        return state.syncUnchecked { state in
            return state.value
        }
    }

    func increment() {
        let waiters = state.syncUnchecked { state in
            state.value &+= 1
            let waiters = Array(state.waiters.values)
            state.waiters = [:]
            return waiters
        }

        for waiter in waiters {
            waiter.resume()
        }
    }

    func waitForIncrement(after value: Int) async throws {
        let waiterID = state.syncUnchecked { state in
            state.lastWaiterID &+= 1
            return state.lastWaiterID
        }

        try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Error>) in
                let outcome: Result<Void, any Error>? = state.syncUnchecked { state in
                    if state.value != value {
                        return .success(())
                    }

                    if Task.isCancelled {
                        return .failure(CancellationError())
                    }

                    state.waiters[waiterID] = continuation
                    return nil
                }

                if let outcome {
                    continuation.resume(with: outcome)
                }
            }
        } onCancel: {
            let waiter = state.syncUnchecked { state in
                return state.waiters.removeValue(forKey: waiterID)
            }

            waiter?.resume(throwing: CancellationError())
        }
    }
}
