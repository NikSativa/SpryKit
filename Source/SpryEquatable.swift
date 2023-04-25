import Foundation

/// Used to compare any two arguments. Uses Equatable's `==(lhs:rhs:)` operator for comparision.
///
/// - Important: Never manually implement `_isEqual(to:)` when conform to `SpryEquatable`. Instead rely on the provided extensions.
/// - Note: If a compiler error says you do NOT conform to `SpryEquatable` then conform to `Equatable`. This will remove the error.
public protocol SpryEquatable {
    func _isEqual(to actual: Any?) -> Bool
}

// MARK: - common implementation

public extension SpryEquatable {
    func _isEqual(to actual: Any?) -> Bool {
        Constant.FatalError.doesNotConformToEquatable(self)
    }
}

// MARK: - Equatable

public extension SpryEquatable where Self: Equatable {
    func _isEqual(to actual: Any?) -> Bool {
        if let actual = actual as? Self {
            return self == actual
        }
        return false
    }
}

// MARK: - AnyObject

public extension SpryEquatable where Self: AnyObject {
    func _isEqual(to actual: Any?) -> Bool {
        if let actual = actual as? Self {
            return self === actual
        }
        return false
    }
}

// MARK: - AnyObject & Equatable

public extension SpryEquatable where Self: AnyObject & Equatable {
    func _isEqual(to actual: Any?) -> Bool {
        if let actual = actual as? Self {
            return self == actual
        }

        if let actual = actual as? AnyObject {
            return self === actual
        }

        return false
    }
}
