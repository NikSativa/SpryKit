import Foundation
import NSpry

final class SpryEquatableTestHelper: SpryEquatable {
    let isEqual: Bool

    init(isEqual: Bool) {
        self.isEqual = isEqual
    }

    func _DO_NOT_OVERRIDE_isEqual(to actual: Any?) -> Bool {
        return isEqual
    }
}

final class NotSpryEquatable {}

final class AnyObjectAndEquatable: Equatable, SpryEquatable {
    static func ==(_: AnyObjectAndEquatable, _: AnyObjectAndEquatable) -> Bool {
        return true
    }
}

final class AnyObjectOnly: SpryEquatable {
    let p: Int

    init(p: Int) {
        self.p = p
    }
}
