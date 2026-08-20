import Foundation

public extension Spry {
    /// Drops every recorded call and every stub, for every fake in the process.
    ///
    /// Instance state goes away with the fake that owns it, but a type keeps its class-level calls
    /// and stubs for the lifetime of the process — a fake's `ClassFunction` stubs registered in one
    /// test are still answering in the next one. Call this from a global teardown to stop that
    /// leaking between tests.
    ///
    /// ## Examples ##
    /// ```swift
    /// override func tearDown() {
    ///     super.tearDown()
    ///     Spry.resetAll()
    /// }
    /// ```
    static func resetAll() {
        removeAllRecordedCalls()
        removeAllStubs()
    }
}
