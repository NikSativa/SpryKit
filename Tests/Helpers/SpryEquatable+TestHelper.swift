import Foundation
import NSpry

final class SpryEquatableTestHelper: SpryEquatable {
    let isEqual: Bool
    private(set) var lastValueCompared: SpryEquatable?

    init(isEqual: Bool) {
        self.isEqual = isEqual
    }

    func _isEqual(to actual: SpryEquatable?) -> Bool {
        lastValueCompared = actual
        return isEqual
    }
}

class NotSpryEquatable {}

final class AnyObjectAndEquatable: Equatable, SpryEquatable {
    public static func ==(_: AnyObjectAndEquatable, _: AnyObjectAndEquatable) -> Bool {
        return true
    }
}

final class AnyObjectOnly: SpryEquatable {}
