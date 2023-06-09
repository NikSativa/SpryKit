import Foundation

/// Used to compare any two arguments. Uses Equatable's `==(lhs:rhs:)` operator for comparision.
///
/// - Remark: Use it if you are using your custom implementation of 'Equatable'
/// - Important: Never manually implement `_DO_NOT_OVERRIDE_isEqual(to:)` when conform to `SpryEquatable`. Instead rely on the provided extensions.
public protocol SpryEquatable {
    func _DO_NOT_OVERRIDE_isEqual(to actual: Any?) -> Bool
}

// MARK: - common implementation

public extension SpryEquatable {
    func _DO_NOT_OVERRIDE_isEqual(to actual: Any?) -> Bool {
        if let actual = actual as? Self {
            return isAnyEqual(self, actual)
        }
        return false
    }
}

// MARK: - Equatable

public extension SpryEquatable where Self: Equatable {
    func _DO_NOT_OVERRIDE_isEqual(to actual: Any?) -> Bool {
        if let actual = actual as? Self {
            return self == actual
        }
        return false
    }
}
