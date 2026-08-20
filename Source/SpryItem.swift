import Foundation

protocol SpryItem: AnyObject, Equatable {
    var arguments: [Any?] { get }
    var functionName: String { get }
    var chronologicalIndex: Int { get set }
    var isComplete: Bool { get }
}

extension SpryItem {
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.functionName == rhs.functionName
            && lhs.arguments.count == rhs.arguments.count
            && lhs.arguments.compare(with: rhs.arguments)
    }
}
