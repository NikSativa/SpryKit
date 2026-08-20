#if canImport(SwiftSyntax600)
import SwiftDiagnostics

enum SpryableDiagnostic: DiagnosticMessage, Error {
    case onlyApplicableToClass
    case notAVariable
    case onlyApplicableToVar
    case notAFunction
    case nonEscapingClosureNotSupported
    case subscriptsNotSupported
    case operatorsNotSupported
    case invalidVariableRequirement
    case typedThrowsNotSupported
    case duplicateCaseName(String)

    /// Provides a human-readable diagnostic message for each diagnostic case.
    var message: String {
        switch self {
        case .onlyApplicableToClass:
            return "`@Spryable` can only be applied to a `class`"
        case .notAVariable:
            return "`@Spryable` can only be applied to a `variable`"
        case .onlyApplicableToVar:
            return "`@Spryable` can only be applied to a computed property (`var`)"
        case .notAFunction:
            return "`@Spryable` can only be applied to a `function`"
        case .subscriptsNotSupported:
            return "Subscript requirements are not supported by `@Spryable`"
        case .operatorsNotSupported:
            return "Operator requirements are not supported by @Spryable."
        case .invalidVariableRequirement:
            return "Invalid variable requirement. Missing type annotation."
        case .nonEscapingClosureNotSupported:
            return "'Non-escaping' closures are not supported by `@Spryable`. You should write the body of the function of your 'Fake' manually."
        case .typedThrowsNotSupported:
            return "Typed 'throws' is not supported by `@Spryable`. Use untyped 'throws' or write the body of the function of your 'Fake' manually."
        case let .duplicateCaseName(name):
            return "`@Spryable` generated two enum cases named '\(name)'. Rename one of the members so that their generated case names differ."
        }
    }

    /// Specifies the severity level of each diagnostic case.
    var severity: DiagnosticSeverity {
        switch self {
        case .duplicateCaseName,
             .invalidVariableRequirement,
             .nonEscapingClosureNotSupported,
             .notAFunction,
             .notAVariable,
             .onlyApplicableToClass,
             .onlyApplicableToVar,
             .operatorsNotSupported,
             .subscriptsNotSupported,
             .typedThrowsNotSupported:
            return .error
        }
    }

    /// Unique identifier for each diagnostic message, facilitating precise error tracking.
    var diagnosticID: MessageID {
        return MessageID(domain: "SpryableMacros", id: identifier)
    }

    private var identifier: String {
        switch self {
        case .onlyApplicableToClass:
            return "onlyApplicableToClass"
        case .notAVariable:
            return "notAVariable"
        case .onlyApplicableToVar:
            return "onlyApplicableToVar"
        case .notAFunction:
            return "notAFunction"
        case .nonEscapingClosureNotSupported:
            return "nonEscapingClosureNotSupported"
        case .subscriptsNotSupported:
            return "subscriptsNotSupported"
        case .operatorsNotSupported:
            return "operatorsNotSupported"
        case .invalidVariableRequirement:
            return "invalidVariableRequirement"
        case .typedThrowsNotSupported:
            return "typedThrowsNotSupported"
        case .duplicateCaseName:
            return "duplicateCaseName"
        }
    }
}
#endif
