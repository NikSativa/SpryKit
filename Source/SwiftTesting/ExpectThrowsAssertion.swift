#if canImport(Testing)
import CwlPreconditionTesting
import Foundation
import Testing

/// Verifies that an expression throws an assertion (precondition failure).
///
/// ## Examples ##
/// ```swift
/// @Test func testAssertion() {
///     expectThrowsAssertion {
///         precondition(false, "Should fail")
///     }
///     // Or with autoclosure:
///     expectThrowsAssertion(precondition(false, "Should fail"))
/// }
/// ```
///
/// - Important: This function is only supported on macOS, iOS, and visionOS with x86_64 or arm64 architecture.
///
/// - Parameter message: Optional custom message for the assertion
/// - Parameter sourceLocation: The source location for error reporting
/// - Parameter expression: The expression that should throw an assertion
public func expectThrowsAssertion(_ message: String = "",
                                  sourceLocation: SourceLocation = #_sourceLocation,
                                  _ expression: @escaping () throws -> some Any) {
    #if (os(macOS) || os(iOS) || supportsVisionOS) && (arch(x86_64) || arch(arm64))
    print(" --- ⚠️ ignore this assertion in console! this is a result of expectThrowsAssertion ⚠️ --- ")
    let caught = catchBadInstruction(in: {
        do {
            _ = try expression()
        } catch {
            Issue.record("catch error: \(error.localizedDescription). \(message)", sourceLocation: sourceLocation)
        }
    })
    #expect(caught != nil, "\(message)", sourceLocation: sourceLocation)
    #else
    print(" --- ⚠️ this is a result of expectThrowsAssertion. it is not supported on this platform ⚠️ --- ")
    #endif
}

/// Verifies that an expression throws an assertion (precondition failure).
///
/// This overload allows passing the expression directly using autoclosure.
///
/// - Parameter expression: The expression that should throw an assertion (autoclosure)
/// - Parameter message: Optional custom message for the assertion
/// - Parameter sourceLocation: The source location for error reporting
@inline(__always)
public func expectThrowsAssertion(_ expression: @autoclosure @escaping () throws -> some Any,
                                  _ message: String,
                                  sourceLocation: SourceLocation = #_sourceLocation) {
    expectThrowsAssertion(message, sourceLocation: sourceLocation, expression)
}

#endif // canImport(Testing)
