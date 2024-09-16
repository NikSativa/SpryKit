import Foundation

/// Argument specifier used by Spyable and Stubbable. Used for non-Equatable comparision.
public enum Argument {
    /// Only Optional.nil matches this qualification.
    case `nil`
    /// Every value matches this qualification except Optional.none
    case nonNil

    /// Every value matches this qualification.
    case anything

    /// Every value matches this qualification, but not 'Argument.anything'.
    case skipped

    /// Any closure
    case closure

    /// Custom validator
    case validator((Any?) -> Bool)

    /// Convenience function to get an `ArgumentCaptor`.
    ///
    /// Used during stubbing to capture the actual arguments. Allows for more detailed testing on an argument being passed into a `Stubbable`
    ///
    /// - Returns: A new ArgumentCaptor.
    public static func captor() -> ArgumentCaptor {
        return ArgumentCaptor()
    }

    /// Type is exactly the type passed in match this qualification (subtypes do NOT qualify).
    public static func isType<T>(_: T.Type) -> Self {
        return .validator {
            return ($0 as? T.Type) != nil
        }
    }

    /// Only objects whose type is exactly the type passed in match this qualification (subtypes do NOT qualify).
    public static func instanceOf<T>(_: T.Type) -> Self {
        return .validator {
            return $0 is T
        }
    }
}

// MARK: - Equatable

extension Argument: Equatable {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.closure, .closure),
             (.nil, .nil),
             (.nonNil, .nonNil),
             (.skipped, .skipped),
             (.validator, .validator):
            return true

        case (.anything, _),
             (.closure, _),
             (.nil, _),
             (.nonNil, _),
             (.skipped, _),
             (.validator, _):
            return false
        }
    }
}

// MARK: - CustomStringConvertible

extension Argument: CustomStringConvertible {
    private func makeDescription() -> String {
        switch self {
        case .anything:
            return "Argument.anything"
        case .nonNil:
            return "Argument.nonNil"
        case .nil:
            return "Argument.nil"
        case .validator:
            return "Argument.validator"
        case .closure:
            return "Argument.closure"
        case .skipped:
            return "Argument.skipped"
        }
    }

    public var description: String {
        return makeDescription()
    }
}

// MARK: - CustomDebugStringConvertible

extension Argument: CustomDebugStringConvertible {
    public var debugDescription: String {
        return makeDescription()
    }
}

// MARK: - SpryFriendlyStringConvertible

extension Argument: SpryFriendlyStringConvertible {
    public var friendlyDescription: String {
        return makeDescription()
    }
}

// MARK: -

internal func isEqualArgsLists(fakeType: (some Any).Type, functionName: String, specifiedArgs: [Any?], actualArgs: [Any?]) -> Bool {
    guard specifiedArgs.count == actualArgs.count else {
        Constant.FatalError.wrongNumberOfArgsBeingCompared(fakeType: fakeType, functionName: functionName, specifiedArguments: specifiedArgs, actualArguments: actualArgs)
    }

    return isEqualArgsLists(specifiedArgs: specifiedArgs, actualArgs: actualArgs)
}

internal func isEqualArgsLists(specifiedArgs: [Any?], actualArgs: [Any?]) -> Bool {
    guard specifiedArgs.count == actualArgs.count else {
        return false
    }

    for (specifiedArg, actualArg) in zip(specifiedArgs, actualArgs) {
        if !isEqualArgs(specifiedArg: specifiedArg, actualArg: actualArg) {
            return false
        }
    }

    return true
}

private func isEqualArgs(specifiedArg: Any?, actualArg: Any?) -> Bool {
    if let specifiedArgAsArgumentEnum = specifiedArg as? Argument {
        switch specifiedArgAsArgumentEnum {
        case .anything:
            if let actualArg = actualArg as? Argument {
                return actualArg != Argument.skipped
            }
            return true
        case .skipped:
            if let actualArg = actualArg as? Argument {
                return actualArg != Argument.anything
            }
            return true
        case .nonNil:
            return !isNil(actualArg)
        case .nil:
            return isNil(actualArg)
        case .validator(let validator):
            return validator(actualArg)
        case .closure:
            return isClosure(actualArg)
        }
    }

    if specifiedArg is ArgumentCaptor {
        return true
    }

    guard let specifiedArgReal = specifiedArg, let actualArgReal = actualArg else {
        return isNil(specifiedArg) && isNil(actualArg)
    }

    return isAnyEqual(specifiedArgReal, actualArgReal)
}
