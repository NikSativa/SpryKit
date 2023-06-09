import Foundation

/// This is a helper function to find out if a value is nil.
///
/// (x == nil) will only return yes if x is Optional<Type>.none but will return true if x is Optional<Optional<Type\>>.some(Optional<Type>.none)
internal func isNil(_ value: Any?) -> Bool {
    if let unwrappedValue = value {
        let mirror = Mirror(reflecting: unwrappedValue)
        if mirror.displayStyle == .optional {
            return isNil(mirror.children.first)
        }
        return false
    } else {
        return true
    }
}

// MARK: - String Extensions

extension String {
    func removeAfter(startingCharacter character: String) -> String? {
        let range = range(of: character)
        if let lowerBound = range?.lowerBound {
            return String(self[..<lowerBound])
        }

        return nil
    }
}

// MARK: - Array Extensions

internal extension Array {
    /// Splits the array into two separate arrays.
    ///
    /// - Parameter closure: The closure to determine which array each element will be put into. Return `true` to put item in first array and `false` to put it into the second array.
    func bisect(_ closure: (Element) -> Bool) -> ([Element], [Element]) {
        var arrays = ([Element](), [Element]())
        forEach { closure($0) ? arrays.0.append($0) : arrays.1.append($0) }

        return arrays
    }

    func compare(with actual: Any?) -> Bool {
        guard let actual = actual as? [Element] else {
            return false
        }

        return isAnyEqual(self, actual)
    }
}

internal extension Array where Element: Equatable {
    @discardableResult
    mutating func removeFirst(_ element: Element) -> Element? {
        guard let index = firstIndex(of: element) else {
            return nil
        }

        return remove(at: index)
    }
}

internal extension Array {
    @discardableResult
    mutating func removeFirst(where predicate: (Element) -> Bool) -> Element? {
        guard let index = firstIndex(where: predicate) else {
            return nil
        }

        return remove(at: index)
    }
}

internal extension Dictionary {
    func compare(with actual: Any?) -> Bool {
        guard let actual = actual as? [Key: Value] else {
            return false
        }

        return isAnyEqual(self, actual)
    }
}
