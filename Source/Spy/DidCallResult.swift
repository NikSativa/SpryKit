import Foundation

/// The resulting information when using the `didCall()` function.
public final class DidCallResult: CustomStringConvertible, CustomDebugStringConvertible, FriendlyStringConvertible {
    /// `true` if the function was called given the criteria specified, otherwise `false`.
    public let success: Bool

    /// A list of all recorded calls. Helpful information if success if `false`.
    public private(set) lazy var friendlyDescription: String = friendlyDescriptionClosure()

    /// A textual representation of this instance.
    public private(set) lazy var description: String = descriptionClosure()

    /// A debug textual representation of this instance.
    public private(set) lazy var debugDescription: String = descriptionClosure()

    private let descriptionClosure: () -> String
    private let debugDescriptionClosure: () -> String
    private let friendlyDescriptionClosure: () -> String

    internal init(success: Bool,
                  description: @escaping @autoclosure () -> String,
                  debugDescription: @escaping @autoclosure () -> String,
                  friendlyDescription: @escaping @autoclosure () -> String) {
        self.success = success
        self.descriptionClosure = description
        self.debugDescriptionClosure = debugDescription
        self.friendlyDescriptionClosure = friendlyDescription
    }
}
