#if canImport(Testing)
import Foundation
import Testing

// MARK: - DidCallResult Extensions for Swift Testing

public extension DidCallResult {
    /// A convenience property for use with `#expect` macro.
    ///
    /// ## Examples ##
    /// ```swift
    /// @Test func testUserFetch() {
    ///     let fakeService = FakeUserService()
    ///     sut.loadUser()
    ///     #expect(fakeService.didCall(.fetchUser).isSuccess)
    /// }
    /// ```
    var isSuccess: Bool {
        return success
    }
}

#endif // canImport(Testing)
