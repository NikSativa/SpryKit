import Foundation

struct DeadlineLoader: Sendable {
    enum Error: Swift.Error, Equatable {
        case timedOut
    }

    let source: SpryableAsyncTestClass

    func load(within seconds: Int) async throws -> String {
        return try await withThrowingTaskGroup(of: String.self) { group in
            group.addTask {
                return try await source.loadValue()
            }
            group.addTask {
                try await source.pause(seconds: seconds)
                throw Error.timedOut
            }
            defer {
                group.cancelAll()
            }

            guard let firstResult = try await group.next() else {
                throw CancellationError()
            }

            return firstResult
        }
    }
}
