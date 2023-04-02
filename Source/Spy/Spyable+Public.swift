import Foundation

/// A protocol used to spy on an object's function calls. A small amount of boilerplate is requried.
///
/// - Important: All the functions specified in this protocol come with default implementation that should NOT be overridden.
///
/// - Note: The `Spryable` protocol exists as a convenience to conform to both `Spyable` and `Stubbable` at the same time.
public protocol Spyable: AnyObject {
    // MARK: - Instance

    /// The type that represents function names when spying.
    ///
    /// Ideal to use an enum with raw type of `String`. An enum with raw type of `String` also automatically satisfies StringRepresentable protocol.
    ///
    /// Property signatures are just the property name
    ///
    /// Function signatures are the function name with "()" at the end. If there are parameters then the public facing parameter names are listed in order with ":" after each. If a parameter does not have a public facing name then the private name is used instead
    ///
    /// - Note: This associatedtype has the exact same name as Stubbable's so that a single type will satisfy both.
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

    /// Used to record a function call. Must call in every function for Spyable to work properly.
    ///
    /// - Important: Do NOT implement function. Use default implementation provided by Spry.
    ///
    /// - Parameter function: The function signature to be recorded. Defaults to #function.
    /// - Parameter arguments: The function arguments being passed in. Must include all arguments in the proper order for Spyable to work properly.
    func recordCall(functionName: String, arguments: Any?..., file: String, line: Int)

    /// Used to determine if a function has been called with the specified arguments and the amount of times specified.
    ///
    /// - Important: Do NOT implement function. Use default implementation provided by Spry.
    /// - Important: Only use this function if NOT using the provided `haveReceived()` matcher used in conjunction with [Quick/Nimble](https://github.com/Quick).
    ///
    /// - Parameter function: The `Function` specified.
    /// - Parameter arguments: The arguments specified. If this value is an empty array, then any parameters passed into the actual function call will result in a success (i.e. passing in `[]` is equivalent to passing in Argument.anything for every expected parameter.)
    /// - Parameter countSpecifier: Used to specify the amount of times this function needs to be called for a successful result. See `CountSpecifier` for more detials.
    ///
    /// - Returns: A DidCallResult. See `DidCallResult` for more details.
    func didCall(_ function: Function, withArguments arguments: [SpryEquatable?], countSpecifier: CountSpecifier) -> DidCallResult

    /// Removes all recorded calls.
    ///
    /// - Important: Do NOT implement function. Use default implementation provided by Spry.
    ///
    /// - Important: The spied object will have NO way of knowing about calls made before this function is called. Use with caution.
    func resetCalls()

    // MARK: Static

    /// The type that represents function names when spying.
    ///
    /// Ideal to use an enum with raw type of `String`. An enum with raw type of `String` also automatically satisfies StringRepresentable protocol.
    ///
    /// Property signatures are just the property name
    ///
    /// Function signatures are the function name with "()" at the end. If there are parameters then the public facing parameter names are listed in order with ":" after each. If a parameter does not have a public facing name then the private name is used instead
    ///
    /// - Note: This associatedtype has the exact same name as Stubbable's so that a single type will satisfy both.
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

    /// Used to record a function call. Must call in every function for Spyable to work properly.
    ///
    /// - Important: Do NOT implement function. Use default implementation provided by Spry.
    ///
    /// - Parameter function: The function signature to be recorded. Defaults to #function.
    /// - Parameter arguments: The function arguments being passed in. Must include all arguments in the proper order for Spyable to work properly.
    static func recordCall(functionName: String, arguments: Any?..., file: String, line: Int)

    /// Used to determine if a function has been called with the specified arguments and the amount of times specified.
    ///
    /// - Important: Do NOT implement function. Use default implementation provided by Spry.
    /// - Important: Only use this function if NOT using the provided `haveReceived()` matcher used in conjunction with [Quick/Nimble](https://github.com/Quick).
    ///
    /// - Parameter function: The `Function` specified.
    /// - Parameter arguments: The arguments specified. If this value is an empty array, then any parameters passed into the actual function call will result in a success (i.e. passing in `[]` is equivalent to passing in Argument.anything for every expected parameter.)
    /// - Parameter countSpecifier: Used to specify the amount of times this function needs to be called for a successful result. See `CountSpecifier` for more detials.
    ///
    /// - Returns: A DidCallResult. See `DidCallResult` for more details.
    static func didCall(_ function: ClassFunction, withArguments arguments: [SpryEquatable?], countSpecifier: CountSpecifier) -> DidCallResult

    /// Removes all recorded calls.
    ///
    /// - Important: Do NOT implement function. Use default implementation provided by Spry.
    ///
    /// - Important: The spied object will have NO way of knowing about calls made before this function is called. Use with caution.
    static func resetCalls()
}
