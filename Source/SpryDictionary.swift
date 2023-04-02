import Foundation

protocol SpryItem: AnyObject, Equatable {
    var functionName: String { get }
    var chronologicalIndex: Int { get set }
    var isComplete: Bool { get }
}

final class SpryDictionary<T: SpryItem> {
    /// Array of all stubs in chronological order.
    var values: [T] {
        return valuesMap
            .values
            .flatMap { $0 }
            .sorted { $0.chronologicalIndex < $1.chronologicalIndex }
    }

    private var chronologicalIndex: Int = 0

    private var valuesMap: [String: [T]] = [:]

    func append(_ stub: T) {
        var stubs = valuesMap[stub.functionName] ?? []

        chronologicalIndex &+= 1
        stub.chronologicalIndex = chronologicalIndex

        stubs.insert(stub, at: 0)
        valuesMap[stub.functionName] = stubs
    }

    func completedDuplicates(of stub: T) -> [T] {
        var duplicates: [T] = []

        valuesMap[stub.functionName]?.forEach {
            guard $0.chronologicalIndex != stub.chronologicalIndex, stub.isComplete else {
                return
            }

            if $0 == stub {
                duplicates.append($0)
            }
        }

        return duplicates
    }

    func get(for functionName: String) -> [T] {
        return valuesMap[functionName] ?? []
    }

    func remove(stubs removingStubs: [T], forFunctionName functionName: String) {
        var currentStubs = valuesMap[functionName] ?? []

        removingStubs.forEach { removedStub in
            currentStubs.removeFirst { currentStub in
                return currentStub.chronologicalIndex == removedStub.chronologicalIndex
            }
        }

        valuesMap[functionName] = currentStubs
    }

    func clearAll() {
        valuesMap = [:]
    }
}

// MARK: - CustomStringConvertible

extension SpryDictionary: CustomStringConvertible {
    var description: String {
        return String(describing: valuesMap)
    }
}

// MARK: - CustomDebugStringConvertible

extension SpryDictionary: CustomDebugStringConvertible {
    var debugDescription: String {
        return String(describing: valuesMap)
    }
}

// MARK: - FriendlyStringConvertible

extension SpryDictionary: FriendlyStringConvertible {
    var friendlyDescription: String {
        return makeFriendlyDescription(for: values, separator: "; ", closeEach: false)
    }
}
