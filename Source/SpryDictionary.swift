import Foundation

protocol SpryItem: AnyObject, Equatable {
    var arguments: [Any?] { get }
    var functionName: String { get }
    var chronologicalIndex: Int { get set }
    var isComplete: Bool { get }
}

extension SpryItem {
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.functionName == rhs.functionName
            && lhs.arguments.count == rhs.arguments.count
            && lhs.arguments.compare(with: rhs.arguments)
    }
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
