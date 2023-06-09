import Foundation

/// Used to specify arguments when stubbing.
public protocol Stub {
    typealias DoClosure<T> = ([Any?]) throws -> T

    /// Used to specify arguments when stubbing.
    ///
    /// - Note: If no arguments are specified then any arguments may be passed in and the stubbed value will still be returned.
    ///
    /// ## Example ##
    /// ```swift
    /// service.stub("functionSignature").with("expected argument")
    /// ```
    ///
    /// - Parameter arguments: The specified arguments needed for the stub to succeed. See `Argument` for ways other ways of constraining expected arguments besides Equatable.
    ///
    /// - Returns: A stub object used to add additional `with()` or to add `andReturn()` or `andDo()`.
    func with(_ arguments: Any...) -> Self

    /// Used to specify the return value for the stubbed function.
    ///
    /// - Important: This allows `Any` object to be passed in but the stub will ONLY work if the correct type is passed in.
    ///
    /// - Note: ONLY the last `andReturn()`, `andDo()`, or `andThrow()` will be used. If multiple stubs are required (for instance with different argument specifiers) then a different stub object is required (i.e. call the `stub()` function again).
    ///
    /// ## Example ##
    /// ```swift
    /// // arguments do NOT matter
    /// service.stub(.functionSignature).andReturn("stubbed value")
    ///
    /// // arguments matter
    /// service.stub(.functionSignature).with("expected argument").andReturn("stubbed value")
    /// ```
    ///
    /// - Parameter value: The value to be returned by the stubbed function.
    func andReturn(_ value: Any?)

    /// Used to specify the return value for the stubbed function.
    ///
    /// - Important: This allows `Any` object to be passed in but the stub will ONLY work if the correct type is passed in.
    ///
    /// - Note: ONLY the last `andReturn()`, `andDo()`, or `andThrow()` will be used. If multiple stubs are required (for instance with different argument specifiers) then a different stub object is required (i.e. call the `stub()` function again).
    ///
    /// ## Example ##
    /// ```swift
    /// // arguments do NOT matter
    /// service.stub(.functionSignature).andReturn("stubbed value")
    ///
    /// // arguments matter
    /// service.stub(.functionSignature).with("expected argument").andReturn("stubbed value")
    /// ```
    ///
    /// - Parameter value: The value to be returned by the stubbed function.
    func andReturn()

    /// Used to specify a closure to be executed in place of the stubbed function.
    ///
    /// - Note: ONLY the last `andReturn()`, `andDo()`, or `andThrow()` will be used. If multiple stubs are required (for instance with different argument specifiers) then a different stub object is required (i.e. call the `stub()` function again).
    ///
    /// ## Example ##
    /// ```swift
    /// // arguments do NOT matter (closure will be called if `functionSignature()` is called)
    /// service.stub(.functionSignature).andDo { arguments in
    ///    // do test specific things (like call a completion block)
    ///    return "stubbed value"
    /// }
    ///
    /// // arguments matter (closure will NOT be called unless the arguments match what is passed in the `with()` function)
    /// service.stub(.functionSignature).with("expected argument").andDo { arguments in
    ///    // do test specific things (like call a completion block)
    ///    return "stubbed value"
    /// }
    /// ```
    ///
    /// - Parameter closure: The closure to be executed. The array of parameters that will be passed in correspond to the parameters being passed into the stubbed function. The return value must match the stubbed function's return type and will be the return value of the stubbed function.
    func andDo(_ closure: @escaping DoClosure<Any?>)

    /// Used to specify a closure to be executed in place of the stubbed function.
    ///
    /// - Note: ONLY the last `andReturn()`, `andDo()`, or `andThrow()` will be used. If multiple stubs are required (for instance with different argument specifiers) then a different stub object is required (i.e. call the `stub()` function again).
    ///
    /// ## Example ##
    /// ```swift
    /// // arguments do NOT matter (closure will be called if `functionSignature()` is called)
    /// service.stub(.functionSignature).andDo { arguments in
    ///    // do test specific things (like call a completion block)
    /// }
    ///
    /// // arguments matter (closure will NOT be called unless the arguments match what is passed in the `with()` function)
    /// service.stub(.functionSignature).with("expected argument").andDo { arguments in
    ///    // do test specific things (like call a completion block)
    /// }
    /// ```
    ///
    /// - Parameter closure: The closure to be executed. The array of parameters that will be passed in correspond to the parameters being passed into the stubbed function.
    func andDoVoid(_ closure: @escaping DoClosure<Void>)

    /// Used to throw a Swift `Error` for the stubbed function.
    ///
    /// - Important: Only use this on functions that can throw an Error. Must return `SpryifyThrows()` or `StubbedValueThrows()` in throwing functions when making a fake object.
    ///
    /// - Note: ONLY the last `andReturn()`, `andDo()`, or `andThrow()` will be used. If multiple stubs are required (for instance with different argument specifiers) then a different stub object is required (i.e. call the `stub()` function again).
    ///
    /// ## Example ##
    /// ```swift
    /// // arguments do NOT matter
    /// service.stub(.functionSignatureOfThrowingFunction).andThrow(CustomSwiftError())
    ///
    /// // arguments matter
    /// service.stub(.functionSignatureOfThrowingFunction).with("expected argument").andReturn(CustomSwiftError())
    /// ```
    ///
    /// - Parameter error: The error to be thrown by the stubbed function.
    func andThrow(_ error: Error)
}
