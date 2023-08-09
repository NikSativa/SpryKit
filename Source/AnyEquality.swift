import Foundation

@inline(__always)
public func isAnyEqual(_ lhs: Any?, _ rhs: Any?) -> Bool {
    guard let lhs, let rhs else {
        return lhs == nil && rhs == nil
    }

    return isAnyEqual(lhs, rhs)
}

@inline(__always)
private func isAnyEqual(_ lhs: Any, _ rhs: Any) -> Bool {
    let lhsMirror = Mirror(reflecting: lhs)
    let rhsMirror = Mirror(reflecting: rhs)

    guard let lhsStyle = lhsMirror.displayStyle,
          let rhsStyle = rhsMirror.displayStyle else {
        return areAssociatedValuesEqual(lhs, rhs)
    }

    switch (lhsStyle, rhsStyle) {
    case (.class, .class),
         (.struct, .struct):
        guard lhsMirror.subjectType == rhsMirror.subjectType else {
            return false
        }

        if let lhs = lhs as? AnyHashable,
           let rhs = rhs as? AnyHashable {
            return lhs == rhs
        }

        return manualDictionaryEquality(lhsMirror: lhsMirror, rhsMirror: rhsMirror)
    case (.dictionary, .dictionary):
        return manualDictionaryEquality(lhsMirror: lhsMirror, rhsMirror: rhsMirror)
    case (.enum, .enum):
        guard lhsMirror.subjectType == rhsMirror.subjectType else {
            return false
        }
        return areEnumCasesEqual(lhs: lhs, rhs: rhs, lhsMirror: lhsMirror, rhsMirror: rhsMirror)
    case (.tuple, .tuple):
        // ignore labels as dev's sugar
        return manualArrayEquality(lhsMirror: lhsMirror, rhsMirror: rhsMirror)
    case (.collection, .collection):
        return manualArrayEquality(lhsMirror: lhsMirror, rhsMirror: rhsMirror)
    case (.set, .set):
        return manualSetEquality(lhsMirror: lhsMirror, rhsMirror: rhsMirror)
    case (.optional, .optional):
        let lhsUnwrapped = unwrapOptionalIfPossible(lhsMirror)
        let rhsUnwrapped = unwrapOptionalIfPossible(rhsMirror)

        if lhsUnwrapped == nil, lhsUnwrapped == nil {
            return true
        }

        if let lhsUnwrapped,
           let rhsUnwrapped {
            return isAnyEqual(lhsUnwrapped, rhsUnwrapped)
        }
    case (.optional, _):
        if let lhsUnwrapped = unwrapOptionalIfPossible(lhsMirror) {
            return isAnyEqual(lhsUnwrapped, rhs)
        }
    case (_, .optional):
        if let rhsUnwrapped = unwrapOptionalIfPossible(rhsMirror) {
            return isAnyEqual(lhs, rhsUnwrapped)
        }
    case (_, .class),
         (_, .collection),
         (_, .dictionary),
         (_, .enum),
         (_, .set),
         (_, .struct),
         (_, .tuple),
         (.class, _),
         (.collection, _),
         (.dictionary, _),
         (.enum, _),
         (.set, _),
         (.struct, _),
         (.tuple, _):
        break
    @unknown default:
        break
    }

    return false
}

@inline(__always)
private func areAssociatedValuesEqual(_ lhs: Any, _ rhs: Any) -> Bool {
    if let lhs = lhs as? AnyHashable, let rhs = rhs as? AnyHashable {
        return lhs == rhs
    }

    if let lhs = lhs as? SpryEquatable, let rhs = rhs as? SpryEquatable {
        return lhs._DO_NOT_OVERRIDE_isEqual(to: rhs)
    }

    return false
}

@inline(__always)
private func unwrapOptionalIfPossible(_ mirror: Mirror) -> Any? {
    if let (_, value) = mirror.children.first {
        return value
    }
    return nil
}

@inline(__always)
private func areEnumCasesEqual(lhs: Any, rhs: Any, lhsMirror: Mirror, rhsMirror: Mirror) -> Bool {
    // Make sure that both enums have or don't have associated values
    guard lhsMirror.children.isEmpty == rhsMirror.children.isEmpty else {
        return false
    }

    // If an enum has NO children than it has no associated values
    // therefore the string representations will represent the enum case
    if lhsMirror.children.isEmpty {
        let lRaw = String(reflecting: lhs)
        let rRaw = String(reflecting: rhs)
        return lRaw == rRaw
    }

    // If an enum HAS children than the case name is the used as the label to associated values
    guard let lhsCaseName = lhsMirror.children.first?.label,
          let rhsCaseName = rhsMirror.children.first?.label else {
        fatalError("Swift is not laying out an enum in the expected way in Mirror")
    }

    // Make sure that both enums names are equal
    guard lhsCaseName == rhsCaseName else {
        return false
    }

    return manualDictionaryEquality(lhsMirror: lhsMirror, rhsMirror: rhsMirror)
}

// MARK: - Private Helpers

@inline(__always)
private func isAFunction(value: Any) -> Bool {
    return String(describing: value) == "(Function)"
}

@inline(__always)
private func typeNameWithOutGenerics<T>(_: T.Type) -> String {
    let type = String(describing: T.self)

    if let typeWithoutGeneric = type.split(separator: "<").first {
        return String(typeWithoutGeneric)
    }

    return type
}

@inline(__always)
private func manualDictionaryEquality(lhsMirror: Mirror, rhsMirror: Mirror) -> Bool {
    let lhsDictionary = convertMirrorToDictionary(mirror: lhsMirror)
    let rhsDictionary = convertMirrorToDictionary(mirror: rhsMirror)

    let lhsKeySet = Set<AnyHashable>(lhsDictionary.keys)
    let rhsKeySet = Set<AnyHashable>(rhsDictionary.keys)

    guard lhsKeySet == rhsKeySet else {
        return false
    }

    for lhsKey in lhsDictionary.keys {
        guard let lhsValue = lhsDictionary[lhsKey], let rhsValue = rhsDictionary[lhsKey] else {
            // key doesn't not exist in both dictionaries
            return false
        }

        guard isAnyEqual(lhsValue, rhsValue) else {
            // values for the same key are not equal
            return false
        }
    }

    return true
}

@inline(__always)
private func convertMirrorToDictionary(mirror: Mirror) -> [AnyHashable: Any] {
    var dictionary: [AnyHashable: Any] = [:]

    for child in mirror.children {
        if let label = child.label {
            dictionary[label] = child.value
        } else if let pair = child.value as? (key: AnyHashable, value: Any) {
            dictionary[pair.key] = pair.value
        } else {
            fatalError("Unable to reconstruct dictionary from a Mirror with a `displatyStyle` of `.dictionary`")
        }
    }

    return dictionary
}

@inline(__always)
private func manualArrayEquality(lhsMirror: Mirror, rhsMirror: Mirror) -> Bool {
    let lhsArray = convertMirrorToArray(mirror: lhsMirror)
    let rhsArray = convertMirrorToArray(mirror: rhsMirror)

    guard lhsArray.count == rhsArray.count else {
        return false
    }

    for (l, r) in zip(lhsArray, rhsArray) {
        if !isAnyEqual(l, r) {
            return false
        }
    }

    return true
}

@inline(__always)
private func convertMirrorToArray(mirror: Mirror) -> [Any] {
    var array: [Any] = []

    for child in mirror.children {
        array.append(child.value)
    }

    return array
}

@inline(__always)
private func manualSetEquality(lhsMirror: Mirror, rhsMirror: Mirror) -> Bool {
    let lhsSet = convertMirrorToSet(mirror: lhsMirror)
    let rhsSet = convertMirrorToSet(mirror: rhsMirror)

    guard lhsSet.count == rhsSet.count else {
        return false
    }

    return lhsSet == rhsSet
}

@inline(__always)
private func convertMirrorToSet(mirror: Mirror) -> Set<AnyHashable> {
    var result: Set<AnyHashable> = []

    for child in mirror.children {
        if let value = child.value as? AnyHashable {
            let r = result.insert(value)
            assert(r.inserted, "duplicates found")
        } else {
            fatalError("Unable to reconstruct dictionary from a Mirror with a `displatyStyle` of `.dictionary`")
        }
    }

    return result
}
