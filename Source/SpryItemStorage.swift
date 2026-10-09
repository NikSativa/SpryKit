import Foundation
import Threading

@preconcurrency
final class SpryItemStorage<T: SpryItem>: @unchecked Sendable {
    /// Array of all stubs in chronological order.
    var values: [T] {
        return $valuesMap.syncUnchecked { valuesMap in
            return valuesMap.values
                .flatMap { $0 }
                .sorted { $0.chronologicalIndex < $1.chronologicalIndex }
        }
    }

    var appendCount: Int {
        return appendCounter.value
    }

    private var chronologicalIndex: Int = 0
    private let appendCounter = AwaitableCounter()

    @AtomicValue
    private var valuesMap: [String: [T]] = [:]

    func append(_ stub: T) {
        $valuesMap.syncUnchecked { valuesMap in
            var stubs = valuesMap[stub.functionName] ?? []

            chronologicalIndex &+= 1
            stub.chronologicalIndex = chronologicalIndex

            stubs.insert(stub, at: 0)
            valuesMap[stub.functionName] = stubs
        }

        appendCounter.increment()
    }

    func waitForAppend(after appendCount: Int) async throws {
        try await appendCounter.waitForIncrement(after: appendCount)
    }

    func completedDuplicates(of stub: T) -> [T] {
        $valuesMap.syncUnchecked { valuesMap in
            var duplicates: [T] = []

            for cached in valuesMap[stub.functionName] ?? [] {
                guard cached.chronologicalIndex != stub.chronologicalIndex, stub.isComplete else {
                    continue
                }

                if cached == stub {
                    duplicates.append(cached)
                }
            }

            return duplicates
        }
    }

    func get(for functionName: String) -> [T] {
        return $valuesMap.syncUnchecked { valuesMap in
            return valuesMap[functionName] ?? []
        }
    }

    func remove(stubs removingStubs: [T], forFunctionName functionName: String) {
        $valuesMap.syncUnchecked { valuesMap in
            var currentStubs = valuesMap[functionName] ?? []

            for removedStub in removingStubs {
                currentStubs.removeFirst { currentStub in
                    return currentStub.chronologicalIndex == removedStub.chronologicalIndex
                }
            }

            valuesMap[functionName] = currentStubs
        }
    }

    func clearAll() {
        $valuesMap.syncUnchecked { valuesMap in
            valuesMap = [:]
        }
    }
}

// MARK: - CustomStringConvertible

extension SpryItemStorage: CustomStringConvertible {
    var description: String {
        $valuesMap.syncUnchecked { valuesMap in
            return String(describing: valuesMap)
        }
    }
}

// MARK: - CustomDebugStringConvertible

extension SpryItemStorage: CustomDebugStringConvertible {
    var debugDescription: String {
        $valuesMap.syncUnchecked { valuesMap in
            return String(describing: valuesMap)
        }
    }
}

// MARK: - SpryFriendlyStringConvertible

extension SpryItemStorage: SpryFriendlyStringConvertible {
    var friendlyDescription: String {
        return makeFriendlyDescription(for: values, separator: "; ", closeEach: false)
    }
}
