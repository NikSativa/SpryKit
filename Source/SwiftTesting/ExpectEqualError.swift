#if canImport(Testing)
import Foundation
import Testing

/// Verifies that two errors are equal.
///
/// ## Examples ##
/// ```swift
/// @Test func testErrorEquality() {
///     expectEqualError(MyError.invalid) {
///         throw MyError.invalid
///     }
/// }
/// ```
///
/// - Parameter expectedError: The expected error
/// - Parameter message: Optional custom message for the assertion
/// - Parameter sourceLocation: The source location for error reporting
/// - Parameter expression: The expression that produces an error
public func expectEqualError<E: Error>(_ expectedError: E,
                                       _ message: String = "",
                                       sourceLocation: SourceLocation = #_sourceLocation,
                                       _ expression: () throws -> E?) where E: Equatable {
    do {
        let actualError = try expression()
        guard let actualError else {
            Issue.record("Expected error \(expectedError) but actual error is nil. \(message)", sourceLocation: sourceLocation)
            return
        }

        #expect((actualError as NSError) == (expectedError as NSError), "\(message)", sourceLocation: sourceLocation)
    } catch {
        Issue.record("Unexpected error thrown: \(error.localizedDescription). \(message)", sourceLocation: sourceLocation)
    }
}

/// Verifies that two errors are not equal.
///
/// - Parameter expectedError: The expected error
/// - Parameter message: Optional custom message for the assertion
/// - Parameter sourceLocation: The source location for error reporting
/// - Parameter expression: The expression that produces an error
public func expectNotEqualError<E: Error>(_ expectedError: E,
                                          _ message: String = "",
                                          sourceLocation: SourceLocation = #_sourceLocation,
                                          _ expression: () throws -> E?) where E: Equatable {
    do {
        let actualError = try expression()
        guard let actualError else {
            Issue.record("Expected error \(expectedError) but actual error is nil. \(message)", sourceLocation: sourceLocation)
            return
        }

        #expect((actualError as NSError) != (expectedError as NSError), "\(message)", sourceLocation: sourceLocation)
    } catch {
        Issue.record("Unexpected error thrown: \(error.localizedDescription). \(message)", sourceLocation: sourceLocation)
    }
}

/// Verifies that two errors are equal (direct comparison).
///
/// - Parameter lhs: The left-hand side error
/// - Parameter rhs: The right-hand side error
/// - Parameter message: Optional custom message for the assertion
/// - Parameter sourceLocation: The source location for error reporting
public func expectEqualError<E: Error>(_ lhs: E?,
                                       _ rhs: E?,
                                       _ message: String = "",
                                       sourceLocation: SourceLocation = #_sourceLocation) where E: Equatable {
    guard let rhs else {
        Issue.record("Expected error is nil, use `#expect(lhs == nil)` instead. \(message)")
        return
    }
    guard let lhs else {
        Issue.record("Actual error is nil, use `#expect(rhs == nil)` instead. \(message)")
        return
    }

    #expect((lhs as NSError) == (rhs as NSError), "\(message)", sourceLocation: sourceLocation)
}

/// Verifies that two errors are not equal (direct comparison).
///
/// - Parameter lhs: The left-hand side error
/// - Parameter rhs: The right-hand side error
/// - Parameter message: Optional custom message for the assertion
/// - Parameter sourceLocation: The source location for error reporting
public func expectNotEqualError<E: Error>(_ lhs: E?,
                                          _ rhs: E?,
                                          _ message: String = "",
                                          sourceLocation: SourceLocation = #_sourceLocation) where E: Equatable {
    guard let rhs else {
        Issue.record("Expected error is nil, use `#expect(lhs == nil)` instead. \(message)", sourceLocation: sourceLocation)
        return
    }
    guard let lhs else {
        Issue.record("Actual error is nil, use `#expect(rhs == nil)` instead. \(message)", sourceLocation: sourceLocation)
        return
    }

    #expect((lhs as NSError) != (rhs as NSError), "\(message)", sourceLocation: sourceLocation)
}

#endif // canImport(Testing)
