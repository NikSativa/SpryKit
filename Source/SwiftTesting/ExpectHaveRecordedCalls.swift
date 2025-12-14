#if canImport(Testing)
import Foundation
import Testing

// MARK: - Private Helpers

private func descriptionOfActual(count: Int) -> String {
    let pluralism = count == 1 ? "" : "s"
    return "have recorded \(count) call\(pluralism)"
}

// MARK: - public

/// Matcher used to determine if at least one call has been made.
///
/// - Important: This function respects `resetCalls()`. If calls have been made, then afterward `resetCalls()` is called. It is expected that hasRecordedCalls to be false.
///
/// ## Examples ##
/// ```swift
/// @Test func testHasCalls() {
///     let fakeService = FakeUserService()
///     fakeService.loadUser()
///     expectHaveRecordedCalls(fakeService)
/// }
/// ```
///
/// - Parameter spyable: The spyable object to check
/// - Parameter message: Optional custom message for the assertion
/// - Parameter sourceLocation: The source location for error reporting
public func expectHaveRecordedCalls(_ spyable: some Spyable,
                                    _ message: String? = nil,
                                    sourceLocation: SourceLocation = #_sourceLocation) {
    let defaultMessage = message ?? descriptionOfActual(count: spyable.recordedCallsCount)
    #expect(spyable.haveRecordedCalls, "Expected to \(defaultMessage)", sourceLocation: sourceLocation)
}

/// Matcher used to determine if has not been made call.
///
/// - Important: This function respects `resetCalls()`. If calls have been made, then afterward `resetCalls()` is called. It is expected that hasRecordedCalls to be false.
///
/// ## Examples ##
/// ```swift
/// @Test func testNoCalls() {
///     let fakeService = FakeUserService()
///     expectHaveNoRecordedCalls(fakeService)
/// }
/// ```
///
/// - Parameter spyable: The spyable object to check
/// - Parameter message: Optional custom message for the assertion
/// - Parameter sourceLocation: The source location for error reporting
public func expectHaveNoRecordedCalls(_ spyable: some Spyable,
                                      _ message: String? = nil,
                                      sourceLocation: SourceLocation = #_sourceLocation) {
    let defaultMessage = message ?? descriptionOfActual(count: spyable.recordedCallsCount)
    #expect(!spyable.haveRecordedCalls, "Expected to not \(defaultMessage)", sourceLocation: sourceLocation)
}

/// Matcher used to determine if at least one call has been made on a class.
///
/// - Important: This function respects `resetCalls()`. If calls have been made, then afterward `resetCalls()` is called. It is expected that hasRecordedCalls to be false.
///
/// - Parameter spyable: The spyable class type to check
/// - Parameter message: Optional custom message for the assertion
/// - Parameter sourceLocation: The source location for error reporting
public func expectHaveRecordedCalls(_ spyable: (some Spyable).Type,
                                    _ message: String? = nil,
                                    sourceLocation: SourceLocation = #_sourceLocation) {
    let defaultMessage = message ?? descriptionOfActual(count: spyable.recordedCallsCount)
    #expect(spyable.haveRecordedCalls, "Expected to \(defaultMessage)", sourceLocation: sourceLocation)
}

/// Matcher used to determine if has not been made call on a class.
///
/// - Important: This function respects `resetCalls()`. If calls have been made, then afterward `resetCalls()` is called. It is expected that hasRecordedCalls to be false.
///
/// - Parameter spyable: The spyable class type to check
/// - Parameter message: Optional custom message for the assertion
/// - Parameter sourceLocation: The source location for error reporting
public func expectHaveNoRecordedCalls(_ spyable: (some Spyable).Type,
                                      _ message: String? = nil,
                                      sourceLocation: SourceLocation = #_sourceLocation) {
    let defaultMessage = message ?? descriptionOfActual(count: spyable.recordedCallsCount)
    #expect(!spyable.haveRecordedCalls, "Expected to not \(defaultMessage)", sourceLocation: sourceLocation)
}

#endif // canImport(Testing)
