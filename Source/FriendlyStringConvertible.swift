import Foundation

public protocol FriendlyStringConvertible {
    /// A beautified description. Used for logging.
    var friendlyDescription: String { get }
}

@inline(__always)
internal func makeFriendlyDescription(for obj: Any?, close: Bool) -> String {
    guard let obj else {
        return close ? "<nil>" : "nil"
    }

    let str: String
    if let friendly = obj as? FriendlyStringConvertible {
        str = friendly.friendlyDescription
    } else {
        str = String(describing: obj)
    }
    return close ? "<\(str)>" : str
}

@inline(__always)
internal func makeFriendlyDescription(for arguments: [Any?], separator: String, closeEach: Bool) -> String {
    if arguments.isEmpty {
        return "<>"
    }

    let str = arguments.map {
        return makeFriendlyDescription(for: $0, close: closeEach)
    }.joined(separator: separator)
    return str
}
