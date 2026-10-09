import Foundation

/// Convenience protocol to conform to and use Spyable and Stubbable protocols with less effort.
///
/// See Spyable and Stubbable or more information.
public protocol Spryable: Spyable, Stubbable {
    // MARK: Instance

    /// Convenience function to record a call and return a stubbed value.
    ///
    /// See `Spyable`'s `recordCall()` and `Stubbable`'s `stubbedValue()` for more information.
    ///
    /// - Important: Do NOT implement function. Use default implementation provided by Spry.
    ///
    /// - Parameter function: The function signature. Defaults to #function.
    /// - Parameter arguments: The function arguments being passed in.
    /// - Parameter asType: The type to be returned. Defaults to using type inference. Only specify if needed or for performance.
    func spryify<T>(_ functionName: String, arguments: Any?..., asType _: T.Type, file: String, line: Int) -> T

    /// Convenience function to record a call and return a stubbed value.
    ///
    /// See `Spyable`'s `recordCall()` and `Stubbable`'s `stubbedValue()` for more information.
    ///
    /// - Important: Do NOT implement function. Use default implementation provided by Spry.
    ///
    /// - Parameter function: The function signature. Defaults to #function.
    /// - Parameter arguments: The function arguments being passed in.
    /// - Parameter fallbackValue: The fallback value to be used if no stub is found for the given function signature and arguments. Can give false positives when testing. Use with caution.
    func spryify<T>(_ functionName: String, arguments: Any?..., fallbackValue: T, file: String, line: Int) -> T

    /// Convenience function to record a call and return a stubbed value from a throwable function.
    ///
    /// See `Spyable`'s `recordCall()` and `Stubbable`'s `stubbedValueThrows()` for more information.
    ///
    /// - Important: Do NOT implement function. Use default implementation provided by Spry.
    ///
    /// - Parameter function: The function signature. Defaults to #function.
    /// - Parameter arguments: The function arguments being passed in.
    /// - Parameter asType: The type to be returned. Defaults to using type inference. Only specify if needed or for performance.
    func spryifyThrows<T>(_ functionName: String, arguments: Any?..., asType _: T.Type, file: String, line: Int) throws -> T

    /// Convenience function to record a call and return a stubbed value from a throwable function.
    ///
    /// See `Spyable`'s `recordCall()` and `Stubbable`'s `stubbedValue()` for more information.
    ///
    /// - Important: Do NOT implement function. Use default implementation provided by Spry.
    ///
    /// - Parameter function: The function signature. Defaults to #function.
    /// - Parameter arguments: The function arguments being passed in.
    /// - Parameter fallbackValue: The fallback value to be used if no stub is found for the given function signature and arguments. Can give false positives when testing. Use with caution.
    func spryifyThrows<T>(_ functionName: String, arguments: Any?..., fallbackValue: T, file: String, line: Int) throws -> T

    /// Convenience function to record a call and return a stubbed value from an `async` function.
    ///
    /// Unlike `spryify()`, the call is recorded before the stub answers it, so a stub registered with `andWaitForResponse()` keeps the call waiting while `waitForCall()` already sees it.
    ///
    /// - Important: Do NOT implement function. Use default implementation provided by Spry.
    ///
    /// - Note: A non-throwing function cannot report cancellation, so a call waiting for a response keeps waiting after its task is cancelled until the test answers it.
    ///
    /// - Parameter function: The function signature. Defaults to #function.
    /// - Parameter arguments: The function arguments being passed in.
    /// - Parameter asType: The type to be returned. Defaults to using type inference. Only specify if needed or for performance.
    func spryifyAsync<T>(_ functionName: String, arguments: Any?..., asType _: T.Type, file: String, line: Int) async -> T

    /// Convenience function to record a call and return a stubbed value from an `async` function.
    ///
    /// Unlike `spryify()`, the call is recorded before the stub answers it, so a stub registered with `andWaitForResponse()` keeps the call waiting while `waitForCall()` already sees it.
    ///
    /// - Important: Do NOT implement function. Use default implementation provided by Spry.
    ///
    /// - Note: A non-throwing function cannot report cancellation, so a call waiting for a response keeps waiting after its task is cancelled until the test answers it.
    ///
    /// - Parameter function: The function signature. Defaults to #function.
    /// - Parameter arguments: The function arguments being passed in.
    /// - Parameter fallbackValue: The fallback value to be used if no stub is found for the given function signature and arguments. Can give false positives when testing. Use with caution.
    func spryifyAsync<T>(_ functionName: String, arguments: Any?..., fallbackValue: T, file: String, line: Int) async -> T

    /// Convenience function to record a call and return a stubbed value from an `async` throwable function.
    ///
    /// Unlike `spryifyThrows()`, the call is recorded before the stub answers it, so a stub registered with `andWaitForResponse()` keeps the call waiting while `waitForCall()` already sees it.
    ///
    /// - Important: Do NOT implement function. Use default implementation provided by Spry.
    ///
    /// - Note: A call waiting for a response throws `CancellationError` when its task is cancelled.
    ///
    /// - Parameter function: The function signature. Defaults to #function.
    /// - Parameter arguments: The function arguments being passed in.
    /// - Parameter asType: The type to be returned. Defaults to using type inference. Only specify if needed or for performance.
    func spryifyAsyncThrows<T>(_ functionName: String, arguments: Any?..., asType _: T.Type, file: String, line: Int) async throws -> T

    /// Convenience function to record a call and return a stubbed value from an `async` throwable function.
    ///
    /// Unlike `spryifyThrows()`, the call is recorded before the stub answers it, so a stub registered with `andWaitForResponse()` keeps the call waiting while `waitForCall()` already sees it.
    ///
    /// - Important: Do NOT implement function. Use default implementation provided by Spry.
    ///
    /// - Note: A call waiting for a response throws `CancellationError` when its task is cancelled.
    ///
    /// - Parameter function: The function signature. Defaults to #function.
    /// - Parameter arguments: The function arguments being passed in.
    /// - Parameter fallbackValue: The fallback value to be used if no stub is found for the given function signature and arguments. Can give false positives when testing. Use with caution.
    func spryifyAsyncThrows<T>(_ functionName: String, arguments: Any?..., fallbackValue: T, file: String, line: Int) async throws -> T

    /// Removes all recorded calls and stubs.
    ///
    /// - Important: Do NOT implement function. Use default implementation provided by Spry.
    ///
    /// - Important: The spryified object will have NO way of knowing about calls or stubs made before this function is called. Use with caution.
    func resetCallsAndStubs()

    // MARK: - Static

    /// Convenience function to record a call and return a stubbed value.
    ///
    /// See `Spyable`'s `recordCall()` and `Stubbable`'s `stubbedValue()` for more information.
    ///
    /// - Important: Do NOT implement function. Use default implementation provided by Spry.
    ///
    /// - Parameter function: The function signature. Defaults to #function.
    /// - Parameter arguments: The function arguments being passed in.
    /// - Parameter asType: The type to be returned. Defaults to using type inference. Only specify if needed or for performance.
    static func spryify<T>(_ functionName: String, arguments: Any?..., asType _: T.Type, file: String, line: Int) -> T

    /// Convenience function to record a call and return a stubbed value.
    ///
    /// See `Spyable`'s `recordCall()` and `Stubbable`'s `stubbedValue()` for more information.
    ///
    /// - Important: Do NOT implement function. Use default implementation provided by Spry.
    ///
    /// - Parameter function: The function signature. Defaults to #function.
    /// - Parameter arguments: The function arguments being passed in.
    /// - Parameter fallbackValue: The fallback value to be used if no stub is found for the given function signature and arguments. Can give false positives when testing. Use with caution.
    static func spryify<T>(_ functionName: String, arguments: Any?..., fallbackValue: T, file: String, line: Int) -> T

    /// Convenience function to record a call and return a stubbed value from a throwable function.
    ///
    /// See `Spyable`'s `recordCall()` and `Stubbable`'s `stubbedValue()` for more information.
    ///
    /// - Important: Do NOT implement function. Use default implementation provided by Spry.
    ///
    /// - Parameter function: The function signature. Defaults to #function.
    /// - Parameter arguments: The function arguments being passed in.
    /// - Parameter asType: The type to be returned. Defaults to using type inference. Only specify if needed or for performance.
    static func spryifyThrows<T>(_ functionName: String, arguments: Any?..., asType _: T.Type, file: String, line: Int) throws -> T

    /// Convenience function to record a call and return a stubbed value from a throwable function.
    ///
    /// See `Spyable`'s `recordCall()` and `Stubbable`'s `stubbedValue()` for more information.
    ///
    /// - Important: Do NOT implement function. Use default implementation provided by Spry.
    ///
    /// - Parameter function: The function signature. Defaults to #function.
    /// - Parameter arguments: The function arguments being passed in.
    /// - Parameter fallbackValue: The fallback value to be used if no stub is found for the given function signature and arguments. Can give false positives when testing. Use with caution.
    static func spryifyThrows<T>(_ functionName: String, arguments: Any?..., fallbackValue: T, file: String, line: Int) throws -> T

    /// Convenience function to record a call and return a stubbed value from an `async` function.
    ///
    /// Unlike `spryify()`, the call is recorded before the stub answers it, so a stub registered with `andWaitForResponse()` keeps the call waiting while `waitForCall()` already sees it.
    ///
    /// - Important: Do NOT implement function. Use default implementation provided by Spry.
    ///
    /// - Note: A non-throwing function cannot report cancellation, so a call waiting for a response keeps waiting after its task is cancelled until the test answers it.
    ///
    /// - Parameter function: The function signature. Defaults to #function.
    /// - Parameter arguments: The function arguments being passed in.
    /// - Parameter asType: The type to be returned. Defaults to using type inference. Only specify if needed or for performance.
    static func spryifyAsync<T>(_ functionName: String, arguments: Any?..., asType _: T.Type, file: String, line: Int) async -> T

    /// Convenience function to record a call and return a stubbed value from an `async` function.
    ///
    /// Unlike `spryify()`, the call is recorded before the stub answers it, so a stub registered with `andWaitForResponse()` keeps the call waiting while `waitForCall()` already sees it.
    ///
    /// - Important: Do NOT implement function. Use default implementation provided by Spry.
    ///
    /// - Note: A non-throwing function cannot report cancellation, so a call waiting for a response keeps waiting after its task is cancelled until the test answers it.
    ///
    /// - Parameter function: The function signature. Defaults to #function.
    /// - Parameter arguments: The function arguments being passed in.
    /// - Parameter fallbackValue: The fallback value to be used if no stub is found for the given function signature and arguments. Can give false positives when testing. Use with caution.
    static func spryifyAsync<T>(_ functionName: String, arguments: Any?..., fallbackValue: T, file: String, line: Int) async -> T

    /// Convenience function to record a call and return a stubbed value from an `async` throwable function.
    ///
    /// Unlike `spryifyThrows()`, the call is recorded before the stub answers it, so a stub registered with `andWaitForResponse()` keeps the call waiting while `waitForCall()` already sees it.
    ///
    /// - Important: Do NOT implement function. Use default implementation provided by Spry.
    ///
    /// - Note: A call waiting for a response throws `CancellationError` when its task is cancelled.
    ///
    /// - Parameter function: The function signature. Defaults to #function.
    /// - Parameter arguments: The function arguments being passed in.
    /// - Parameter asType: The type to be returned. Defaults to using type inference. Only specify if needed or for performance.
    static func spryifyAsyncThrows<T>(_ functionName: String, arguments: Any?..., asType _: T.Type, file: String, line: Int) async throws -> T

    /// Convenience function to record a call and return a stubbed value from an `async` throwable function.
    ///
    /// Unlike `spryifyThrows()`, the call is recorded before the stub answers it, so a stub registered with `andWaitForResponse()` keeps the call waiting while `waitForCall()` already sees it.
    ///
    /// - Important: Do NOT implement function. Use default implementation provided by Spry.
    ///
    /// - Note: A call waiting for a response throws `CancellationError` when its task is cancelled.
    ///
    /// - Parameter function: The function signature. Defaults to #function.
    /// - Parameter arguments: The function arguments being passed in.
    /// - Parameter fallbackValue: The fallback value to be used if no stub is found for the given function signature and arguments. Can give false positives when testing. Use with caution.
    static func spryifyAsyncThrows<T>(_ functionName: String, arguments: Any?..., fallbackValue: T, file: String, line: Int) async throws -> T

    /// Removes all recorded calls and stubs.
    ///
    /// - Important: Do NOT implement function. Use default implementation provided by Spry.
    ///
    /// - Important: The spryified object will have NO way of knowing about calls or stubs made before this function is called. Use with caution.
    static func resetCallsAndStubs()
}
