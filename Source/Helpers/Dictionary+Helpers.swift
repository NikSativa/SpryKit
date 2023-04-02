import Foundation

extension Dictionary: SpryEquatable {
    public func _isEqual(to actual: Any?) -> Bool {
        guard let castedActual = actual as? [Key: Value] else {
            return false
        }

        if count != castedActual.count {
            return false
        }

        for (key, value) in self {
            guard castedActual.has(key: key), let actualValue = castedActual[key] else {
                return false
            }

            guard let castedValue = value as? SpryEquatable, let castedActualValue = actualValue as? SpryEquatable else {
                Constant.FatalError.doesNotConformToSpryEquatable(value)
            }

            if !castedValue._isEqual(to: castedActualValue) {
                return false
            }
        }

        return true
    }

    private func has(key: Key) -> Bool {
        return contains { $0.key == key }
    }
}
