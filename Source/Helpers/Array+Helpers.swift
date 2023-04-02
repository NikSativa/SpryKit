import Foundation

extension Array: SpryEquatable {
    public func _isEqual(to actual: Any?) -> Bool {
        guard let castedActual = actual as? [Element] else {
            return false
        }

        if count != castedActual.count {
            return false
        }

        return zip(self, castedActual).reduce(true) { result, zippedElements in
            if !result {
                return false
            }

            if let selfElement = zippedElements.0 as? SpryEquatable, let actualElement = zippedElements.1 as? SpryEquatable {
                return selfElement._isEqual(to: actualElement)
            }

            Constant.FatalError.doesNotConformToSpryEquatable(zippedElements.0)
        }
    }
}
