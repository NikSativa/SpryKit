import Foundation
import NSpry

final class SpryEquatableTestHelper: SpryEquatable {
    let isEqual: Bool

    init(isEqual: Bool) {
        self.isEqual = isEqual
    }

    func _isEqual(to actual: Any?) -> Bool {
        return isEqual
    }
}

final class NotSpryEquatable {}

final class AnyObjectAndEquatable: Equatable, SpryEquatable {
    public static func ==(_: AnyObjectAndEquatable, _: AnyObjectAndEquatable) -> Bool {
        return true
    }
}

final class AnyObjectOnly: SpryEquatable {}
