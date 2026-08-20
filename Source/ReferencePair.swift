import Foundation

/// Identity of two objects being compared against each other.
internal struct ReferencePair: Hashable {
    private let lhs: ObjectIdentifier
    private let rhs: ObjectIdentifier

    init(lhs: AnyObject, rhs: AnyObject) {
        self.lhs = ObjectIdentifier(lhs)
        self.rhs = ObjectIdentifier(rhs)
    }
}
