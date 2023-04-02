import Foundation

/// A protocol used to stub an object's functions. A small amount of boilerplate is requried.
///
/// - Important: All the functions specified in this protocol come with default implementation that should NOT be overridden.
///
/// - Note: The `Spryable` protocol exists as a convenience to conform to both `Spyable` and `Stubbable` at the same time.
public protocol Stubbable: AnyObject {
    // MARK: - Instance

    /// The type that represents function and property names when stubbing.
    ///
    /// Ideal to use an enum with raw type of `String`. An enum with raw type of `String` also automatically satisfies StringRepresentable protocol.
    ///
    /// Property signatures are just the property name
    ///
    /// Function signatures are the function name with "()" at the end. If there are parameters then the public facing parameter names are listed in order with ":" after each. If a parameter does not have a public facing name then the private name is used instead
    ///
    /// - Note: This associatedtype has the exact same name as Spyable's so that a single type will satisfy both.
    ///
    /// ## Example ##
    /// ```swift
    /// enum Function: String, StringRepresentable {
    ///    // property signatures are just the property name
    ///    case myProperty = "myProperty"
    ///
    ///    // function signatures are the function name with parameter names listed at the end in "()"
    ///    case giveMeAString = "noParameters()"
    ///    case hereAreTwoParameters = "hereAreTwoParameters(string1:string2:)"
    ///    case paramWithDifferentNames = "paramWithDifferentNames(publicName:)"
    ///    case paramWithNoPublicName = "paramWithNoPublicName(privateName:)"
    /// }
    ///
    /// func noParameters() -> Bool {
    ///    // ...
    /// }
    ///
    /// func hereAreTwoParameters(string1: String, string2: String) -> Bool {
    ///    // ...
    /// }
    ///
    /// func paramWithDifferentNames(publicName privateName: String) -> String {
    ///    // ...
    /// }
    ///
    /// func paramWithNoPublicName(_ privateName: String) -> String {
    ///    // ...
    /// }
    /// ```
    associatedtype Function: StringRepresentable

    /// Used to stub a function. All stubs must be provided either `andReturn()`, `andDo()`, or `andThrow()` to work properly. May also specify arguments using `with()`.
    ///
    /// - Note: If the same function is stubbed with the same argument specifications, then this function will fatal error. Stubbing the same thing again is usually a code smell. If this necessary then use `.stubAgain`.
    ///
    /// - Important: Do NOT implement function. Use default implementation provided by Spry.
    ///
    /// - Parameter function: The `Function` to be stubbed.
    /// - Returns: A `Stub` object. See `Stub` to find out how to specifying arguments and a return value.
    func stub(_ function: Function) -> Stub

    /// Used to stub a function *AGAIN*. All stubs must be provided either `andReturn()`, `andDo()`, or `andThrow()` to work properly. May also specify arguments using `with()`.
    ///
    /// - Note: Stubbing the same thing again is usually a code smell. If this is necessary, then use this function otherwise use `.stub()`.
    ///
    /// - Important: Do NOT implement function. Use default implementation provided by Spry.
    ///
    /// - Parameter function: The `Function` to be stubbed.
    /// - Returns: A `Stub` object. See `Stub` to find out how to specifying arguments and a return value.
    func stubAgain(_ function: Function) -> Stub

    /// Used to return the stubbed value. Must return the result of a `stubbedValue()` or `stubbedValueThrows` in every function for Stubbable to work properly.
    ///
    /// - Important: Do NOT implement function. Use default implementation provided by Spry.
    ///
    /// - Parameter function: The function signature used to find a stub. Defaults to #function.
    /// - Parameter arguments: The function arguments being passed in. Must include all arguments in the proper order for Stubbable to work properly.
    /// - Parameter asType: The type to be returned. Defaults to using type inference. Only specify if needed or for performance.
    func stubbedValue<T>(_ functionName: String, arguments: Any?..., asType _: T.Type, file: String, line: Int) -> T

    /// Used to return the stubbed value. Must return the result of a `stubbedValue()` or `stubbedValueThrows` in every function for Stubbable to work properly.
    ///
    /// - Important: Do NOT implement function. Use default implementation provided by Spry.
    ///
    /// - Parameter function: The function signature used to find a stub. Defaults to #function.
    /// - Parameter arguments: The function arguments being passed in. Must include all arguments in the proper order for Stubbable to work properly.
    /// - Parameter fallbackValue: The fallback value to be used if no stub is found for the given function signature and arguments. Can give false positives when testing. Use with caution. Defaults to .noFallback
    func stubbedValue<T>(_ functionName: String, arguments: Any?..., fallbackValue: T, file: String, line: Int) -> T

    /// Used to return the stubbed value of a function that can throw. Must return the result of a `stubbedValue()` or `stubbedValueThrows` in every function for Stubbable to work properly.
    ///
    /// - Important: Do NOT implement function. Use default implementation provided by Spry.
    ///
    /// - Parameter function: The function signature used to find a stub. Defaults to #function.
    /// - Parameter arguments: The function arguments being passed in. Must include all arguments in the proper order for Stubbable to work properly.
    /// - Parameter asType: The type to be returned. Defaults to using type inference. Only specify if needed or for performance.
    func stubbedValueThrows<T>(_ functionName: String, arguments: Any?..., asType _: T.Type, file: String, line: Int) throws -> T

    /// Used to return the stubbed value of a function that can throw. Must return the result of a `stubbedValue()` or `stubbedValueThrows` in every function for Stubbable to work properly.
    ///
    /// - Important: Do NOT implement function. Use default implementation provided by Spry.
    ///
    /// - Parameter function: The function signature used to find a stub. Defaults to #function.
    /// - Parameter arguments: The function arguments being passed in. Must include all arguments in the proper order for Stubbable to work properly.
    /// - Parameter fallbackValue: The fallback value to be used if no stub is found for the given function signature and arguments. Can give false positives when testing. Use with caution. Defaults to .noFallback
    func stubbedValueThrows<T>(_ functionName: String, arguments: Any?..., fallbackValue: T, file: String, line: Int) throws -> T

    /// Removes all stubs.
    ///
    /// - Important: Do NOT implement function. Use default implementation provided by Spry.
    ///
    /// - Important: The stubbed object will have NO way of knowing about stubs made before this function is called. Use with caution.
    func resetStubs()

    // MARK: - Static

    /// The type that represents class function and property names when stubbing.
    ///
    /// Ideal to use an enum with raw type of `String`. An enum with raw type of `String` also automatically satisfies StringRepresentable protocol.
    ///
    /// Property signatures are just the property name
    ///
    /// Function signatures are the function name with "()" at the end. If there are parameters then the public facing parameter names are listed in order with ":" after each. If a parameter does not have a public facing name then the private name is used instead
    ///
    /// - Note: This associatedtype has the exact same name as Spyable's so that a single type will satisfy both.
    ///
    /// ## Example ##
    /// ```swift
    /// enum ClassFunction: String, StringRepresentable {
    ///    // property signatures are just the property name
    ///    case myProperty = "myProperty"
    ///
    ///    // function signatures are the function name with parameter names listed at the end in "()"
    ///    case giveMeAString = "noParameters()"
    ///    case hereAreTwoParameters = "hereAreTwoParameters(string1:string2:)"
    ///    case paramWithDifferentNames = "paramWithDifferentNames(publicName:)"
    ///    case paramWithNoPublicName = "paramWithNoPublicName(privateName:)"
    /// }
    ///
    /// class func noParameters() -> Bool {
    ///    // ...
    /// }
    ///
    /// class func hereAreTwoParameters(string1: String, string2: String) -> Bool {
    ///    // ...
    /// }
    ///
    /// class func paramWithDifferentNames(publicName privateName: String) -> String {
    ///    // ...
    /// }
    ///
    /// class func paramWithNoPublicName(_ privateName: String) -> String {
    ///    // ...
    /// }
    /// ```
    associatedtype ClassFunction: StringRepresentable

    /// Used to stub a function. All stubs must be provided either `andReturn()`, `andDo()`, or `andThrow()` to work properly. May also specify arguments using `with()`.
    ///
    /// - Important: Do NOT implement function. Use default implementation provided by Spry.
    ///
    /// - Parameter function: The `ClassFunction` to be stubbed.
    /// - Returns: A `Stub` object. See `Stub` to find out how to specifying arguments and a return value.
    static func stub(_ function: ClassFunction) -> Stub

    /// Used to stub a function *AGAIN*. All stubs must be provided either `andReturn()`, `andDo()`, or `andThrow()` to work properly. May also specify arguments using `with()`.
    ///
    /// - Note: Stubbing the same thing again is usually a code smell. If this is necessary, then use this function otherwise use `.stub()`.
    ///
    /// - Important: Do NOT implement function. Use default implementation provided by Spry.
    ///
    /// - Parameter function: The `Function` to be stubbed.
    /// - Returns: A `Stub` object. See `Stub` to find out how to specifying arguments and a return value.
    static func stubAgain(_ function: ClassFunction) -> Stub

    /// Used to return the stubbed value. Must return the result of a `stubbedValue()` or `stubbedValueThrows` in every function for Stubbable to work properly.
    ///
    /// - Important: Do NOT implement function. Use default implementation provided by Spry.
    ///
    /// - Parameter function: The function signature used to find a stub. Defaults to #function.
    /// - Parameter arguments: The function arguments being passed in. Must include all arguments in the proper order for Stubbable to work properly.
    /// - Parameter asType: The type to be returned. Defaults to using type inference. Only specify if needed or for performance.
    static func stubbedValue<T>(_ functionName: String, arguments: Any?..., asType _: T.Type, file: String, line: Int) -> T

    /// Used to return the stubbed value. Must return the result of a `stubbedValue()` or `stubbedValueThrows` in every function for Stubbable to work properly.
    ///
    /// - Important: Do NOT implement function. Use default implementation provided by Spry.
    ///
    /// - Parameter function: The function signature used to find a stub. Defaults to #function.
    /// - Parameter arguments: The function arguments being passed in. Must include all arguments in the proper order for Stubbable to work properly.
    /// - Parameter fallbackValue: The fallback value to be used if no stub is found for the given function signature and arguments. Can give false positives when testing. Use with caution.
    static func stubbedValue<T>(_ functionName: String, arguments: Any?..., fallbackValue: T, file: String, line: Int) -> T

    /// Used to return the stubbed value of a function that can throw. Must return the result of a `stubbedValue()` or `stubbedValueThrows` in every function for Stubbable to work properly.
    ///
    /// - Important: Do NOT implement function. Use default implementation provided by Spry.
    ///
    /// - Parameter function: The function signature used to find a stub. Defaults to #function.
    /// - Parameter arguments: The function arguments being passed in. Must include all arguments in the proper order for Stubbable to work properly.
    /// - Parameter asType: The type to be returned. Defaults to using type inference. Only specify if needed or for performance.
    static func stubbedValueThrows<T>(_ functionName: String, arguments: Any?..., asType _: T.Type, file: String, line: Int) throws -> T

    /// Used to return the stubbed value of a function that can throw. Must return the result of a `stubbedValue()` or `stubbedValueThrows` in every function for Stubbable to work properly.
    ///
    /// - Important: Do NOT implement function. Use default implementation provided by Spry.
    ///
    /// - Parameter function: The function signature used to find a stub. Defaults to #function.
    /// - Parameter arguments: The function arguments being passed in. Must include all arguments in the proper order for Stubbable to work properly.
    /// - Parameter fallbackValue: The fallback value to be used if no stub is found for the given function signature and arguments. Can give false positives when testing. Use with caution.
    static func stubbedValueThrows<T>(_ functionName: String, arguments: Any?..., fallbackValue: T, file: String, line: Int) throws -> T

    /// Removes all stubs.
    ///
    /// - Important: Do NOT implement function. Use default implementation provided by Spry.
    ///
    /// - Important: The stubbed object will have NO way of knowing about stubs made before this function is called. Use with caution.
    static func resetStubs()
}
