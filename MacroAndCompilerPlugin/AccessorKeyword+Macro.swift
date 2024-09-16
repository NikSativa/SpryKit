#if canImport(SwiftSyntax600) && swift(>=6.0)
import Foundation
import SharedTypes

internal extension Array where Element == VarKeyword {
    static func ~=(lhs: [Element], rhs: Element) -> Bool {
        return lhs.contains(rhs)
    }
}

internal extension Array where Element == FuncKeyword {
    static func ~=(lhs: [Element], rhs: Element) -> Bool {
        return lhs.contains(rhs)
    }
}

#endif
