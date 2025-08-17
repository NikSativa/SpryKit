import Foundation

public extension Spry {
    static func diff(_ first: Any?, _ second: Any?) -> String {
        let lhs = encode(first)
        let rhs = encode(second)
        return .spry.diff(lhs, rhs)
    }
}
