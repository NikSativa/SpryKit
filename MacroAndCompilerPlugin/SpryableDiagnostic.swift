#if canImport(SwiftSyntax600) && swift(>=6.0)
import SwiftDiagnostics

enum SpryableDiagnostic: String, DiagnosticMessage, Error {
    case onlyApplicableToClass
    case notAVariable
    case onlyApplicableToVar
    case notAFunction
    case nonEscapingClosureNotSupported
    case subscriptsNotSupported
    case operatorsNotSupported
    case invalidVariableRequirement

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
        }
    }

    /// Specifies the severity level of each diagnostic case.
    var severity: DiagnosticSeverity {
        switch self {
        case .invalidVariableRequirement,
             .nonEscapingClosureNotSupported,
             .notAFunction,
             .notAVariable,
             .onlyApplicableToClass,
             .onlyApplicableToVar,
             .operatorsNotSupported,
             .subscriptsNotSupported:
            return .error
        }
    }

    /// Unique identifier for each diagnostic message, facilitating precise error tracking.
    var diagnosticID: MessageID {
        MessageID(domain: "SpryableMacros", id: rawValue)
    }
}
#endif
