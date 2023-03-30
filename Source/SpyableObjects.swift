import Foundation

/// Used internally. Should never need to use or know about this type.
public final class RecordedCall: CustomStringConvertible, FriendlyStringConvertible {
    // MARK: - Public Properties

    /// A beautified description. Used for debugging purposes.
    public var description: String {
        let argumentsString = arguments.map { "<\($0 as Any)>" }.joined(separator: ", ")
        return "RecordedCall(function: <\(functionName)>, arguments: <\(argumentsString)>)"
    }

    /// A beautified description. Used for logging.
    public var friendlyDescription: String {
        if arguments.isEmpty {
            return functionName
        }

        let arguementListStringRepresentation = makeFriendlyDescription(for: arguments, separator: ", ", closeEach: true)
        return functionName + " with " + arguementListStringRepresentation
    }

    // MARK: - Internal Properties

    /// The function signature of a recorded call. Defaults to `#function`.
    let functionName: String
    /// The arguments passed in when the function was recorded.
    let arguments: [Any?]

    var chronologicalIndex = -1

    // MARK: - Initializers

    init(functionName: String, arguments: [Any?]) {
        self.functionName = functionName
        self.arguments = arguments
    }
}

/// This exists because a dictionary is needed as a class. Instances of this type are put into an NSMapTable.
public final class RecordedCallsDictionary: CustomStringConvertible, FriendlyStringConvertible {
    // MARK: - Public Properties

    /// A beautified description. Used for debugging purposes.
    public var description: String {
        return String(describing: callsDict)
    }

    /// A beautified description. Used for logging.
    public var friendlyDescription: String {
        return makeFriendlyDescription(for: calls, separator: "; ", closeEach: false)
    }

    /// Array of all calls in chronological order
    public var calls: [RecordedCall] {
        return callsDict
            .values
            .flatMap { $0 }
            .sorted { $0.chronologicalIndex < $1.chronologicalIndex }
    }

    /// Number of calls that have been recorded. This number is NOT reset when calls are removed (i.e. `resetCalls()`)
    public private(set) var recordedCount = 0

    // MARK: - Private Properties

    private var callsDict: [String: [RecordedCall]] = [:]

    func add(call: RecordedCall) {
        var calls = callsDict[call.functionName] ?? []

        recordedCount += 1
        call.chronologicalIndex = recordedCount

        calls.insert(call, at: 0)
        callsDict[call.functionName] = calls
    }

    // MARK: - Internal Functions

    func getCalls(for functionName: String) -> [RecordedCall] {
        return callsDict[functionName] ?? []
    }

    func clearAllCalls() {
        callsDict = [:]
    }
}

/// The resulting information when using the `didCall()` function.
public final class DidCallResult: CustomStringConvertible, FriendlyStringConvertible {
    /// `true` if the function was called given the criteria specified, otherwise `false`.
    public let success: Bool

    /// A list of all recorded calls. Helpful information if success if `false`.
    public private(set) lazy var friendlyDescription: String = friendlyDescriptionClosure()

    /// A textual representation of this instance.
    public private(set) lazy var description: String = descriptionClosure()

    private let friendlyDescriptionClosure: () -> String
    private let descriptionClosure: () -> String

    internal init(success: Bool,
                  friendlyDescription: @escaping @autoclosure () -> String,
                  description: @escaping @autoclosure () -> String) {
        self.success = success
        self.friendlyDescriptionClosure = friendlyDescription
        self.descriptionClosure = description
    }
}

/// Used when specifying if a function was called.
public enum CountSpecifier {
    /// Will only succeed if the function was called exactly the number of times specified.
    case exactly(Int)
    /// Will only succeed if the function was called the number of times specified or more.
    case atLeast(Int)
    /// Will only succeed if the function was called the number of times specified or less.
    case atMost(Int)
}
