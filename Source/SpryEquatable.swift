import Foundation

/// Used to compare any two arguments. Uses Equatable's `==(lhs:rhs:)` operator for comparision.
///
/// - Important: Never manually implement `_isEqual(to:)` when conform to `SpryEquatable`. Instead rely on the provided extensions.
/// - Note: If a compiler error says you do NOT conform to `SpryEquatable` then conform to `Equatable`. This will remove the error.
public protocol SpryEquatable {
    func _isEqual(to actual: Any?) -> Bool
}

extension Optional: SpryEquatable where Wrapped: SpryEquatable {}
extension NSObject: SpryEquatable {}
extension String: SpryEquatable {}
extension Bool: SpryEquatable {}
extension CGFloat: SpryEquatable {}
extension Float: SpryEquatable {}
extension Double: SpryEquatable {}
extension Int: SpryEquatable {}
extension Int8: SpryEquatable {}
extension Int16: SpryEquatable {}
extension Int32: SpryEquatable {}
extension Int64: SpryEquatable {}
extension UInt: SpryEquatable {}
extension UInt8: SpryEquatable {}
extension UInt16: SpryEquatable {}
extension UInt32: SpryEquatable {}
extension UInt64: SpryEquatable {}
extension Notification: SpryEquatable {}
extension Notification.Name: SpryEquatable {}
extension Data: SpryEquatable {}
extension DispatchTime: SpryEquatable {}
extension DispatchTimeInterval: SpryEquatable {}
extension URL: SpryEquatable {}
extension URLRequest: SpryEquatable {}
extension TimeZone: SpryEquatable {}

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
