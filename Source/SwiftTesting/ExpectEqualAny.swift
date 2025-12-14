#if canImport(Testing)
import Foundation
import Testing

/// Function that compares two values of any type. This is useful when you need to compare two instances of a class or struct even if they do not conform to the `Equatable` protocol.
///
/// ## Examples ##
/// ```swift
/// struct User {
///     let name: String
///     let age: Int
/// }
/// expectEqualAny(User(name: "John", age: 30), User(name: "John", age: 30))
/// // или
/// #expect(isAnyEqual(User(name: "John", age: 30), User(name: "John", age: 30)))
/// ```
///
/// - Parameter lhs: The left-hand side value to compare
/// - Parameter rhs: The right-hand side value to compare
/// - Parameter message: Optional custom message for the assertion
/// - Parameter sourceLocation: The source location for error reporting
public func expectEqualAny<T>(_ lhs: T?,
                              _ rhs: T?,
                              _ message: String? = nil,
                              sourceLocation: SourceLocation = #_sourceLocation) {
    let isEqual = isAnyEqual(lhs, rhs)
    let defaultMessage = message ?? "\(describe(lhs)) is not equal to \(describe(rhs))\ndiff:\n\(Spry.diffMirror(lhs, rhs))"
    #expect(isEqual, "\(defaultMessage)", sourceLocation: sourceLocation)
}

/// Function that verifies two values of any type are not equal.
///
/// ## Examples ##
/// ```swift
/// expectNotEqualAny(User(name: "Bob", age: 20), User(name: "John", age: 30))
/// ```
///
/// - Parameter lhs: The left-hand side value to compare
/// - Parameter rhs: The right-hand side value to compare
/// - Parameter message: Optional custom message for the assertion
/// - Parameter sourceLocation: The source location for error reporting
public func expectNotEqualAny<T>(_ lhs: T?,
                                 _ rhs: T?,
                                 _ message: String? = nil,
                                 sourceLocation: SourceLocation = #_sourceLocation) {
    let isEqual = isAnyEqual(lhs, rhs)
    let defaultMessage = message ?? "\(describe(lhs)) is equal to \(describe(rhs))\ndiff:\n\(Spry.diffMirror(lhs, rhs))"
    #expect(!isEqual, "\(defaultMessage)", sourceLocation: sourceLocation)
}

#endif // canImport(Testing)
