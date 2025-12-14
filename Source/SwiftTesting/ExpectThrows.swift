#if canImport(Testing)
import Foundation
import Testing

/// Verifies that an expression throws a specific error.
///
/// ## Examples ##
/// ```swift
/// @Test func testThrowsError() {
///     expectThrows(MyError.invalid) {
///         try functionThatThrows()
///     }
/// }
/// ```
///
/// - Parameter expectedError: The expected error that should be thrown
/// - Parameter message: Optional custom message for the assertion
/// - Parameter sourceLocation: The source location for error reporting
/// - Parameter expression: The expression that should throw an error
public func expectThrows<E: Error>(_ expectedError: E,
                                   _ message: String = "",
                                   sourceLocation: SourceLocation = #_sourceLocation,
                                   _ expression: () throws -> some Any) where E: Equatable {
    do {
        _ = try expression()
        Issue.record("Expected error \(expectedError) to be thrown, but expression completed successfully. \(message)", sourceLocation: sourceLocation)
    } catch let actualError {
        if let actualError = actualError as? E {
            #expect((actualError as NSError) == (expectedError as NSError), "\(message)", sourceLocation: sourceLocation)
        } else {
            Issue.record("Expected error \(expectedError) but got \(actualError). \(message)", sourceLocation: sourceLocation)
        }
    }
}

/// Verifies that an expression throws a specific error (alternative parameter order).
///
/// - Parameter expression: The expression that should throw an error
/// - Parameter expectedError: The expected error that should be thrown
/// - Parameter message: Optional custom message for the assertion
/// - Parameter sourceLocation: The source location for error reporting
@inline(__always)
public func expectThrows(_ expression: @autoclosure () throws -> some Any,
                         _ expectedError: some Error & Equatable,
                         _ message: String = "",
                         sourceLocation: SourceLocation = #_sourceLocation) {
    expectThrows(expectedError, message, sourceLocation: sourceLocation, expression)
}

/// Verifies that an expression does not throw an error.
///
/// ## Examples ##
/// ```swift
/// @Test func testNoThrow() {
///     let result = expectNoThrow {
///         try functionThatShouldNotThrow()
///     }
///     #expect(result != nil)
/// }
/// ```
///
/// - Parameter message: Optional custom message for the assertion
/// - Parameter sourceLocation: The source location for error reporting
/// - Parameter expression: The expression that should not throw an error
/// - Returns: The result of the expression, or nil if an error was thrown
@discardableResult
public func expectNoThrow<T>(_ message: String = "",
                             sourceLocation: SourceLocation = #_sourceLocation,
                             _ expression: () throws -> T?) -> T? {
    do {
        return try expression()
    } catch {
        Issue.record("\(message). error: \(error.localizedDescription)", sourceLocation: sourceLocation)
        return nil
    }
}

/// Verifies that an expression does not throw an error (alternative parameter order).
///
/// - Parameter expression: The expression that should not throw an error
/// - Parameter message: Optional custom message for the assertion
/// - Parameter sourceLocation: The source location for error reporting
/// - Returns: The result of the expression, or nil if an error was thrown
@inline(__always)
@discardableResult
public func expectNoThrow<T>(_ expression: @autoclosure () throws -> T?,
                             _ message: String = "",
                             sourceLocation: SourceLocation = #_sourceLocation) -> T? {
    return expectNoThrow(message, sourceLocation: sourceLocation, expression)
}

#endif // canImport(Testing)
