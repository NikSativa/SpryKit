import Foundation

public extension Spry {
    static func diff<T: Encodable>(_ first: T?, _ second: T?, encoder: @autoclosure () -> JSONEncoder = .init()) -> String {
        let lhs = encode(first, encoder: encoder())
        let rhs = encode(second, encoder: encoder())
        return .spry.diff(lhs, rhs)
    }
}
