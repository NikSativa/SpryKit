#if canImport(SwiftSyntax600) && swift(>=6.0)
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public enum SpryableAccessorMacro: AccessorMacro {
    public static func expansion(of node: AttributeSyntax,
                                 providingAccessorsOf declaration: some DeclSyntaxProtocol,
                                 in context: some MacroExpansionContext) throws -> [AccessorDeclSyntax] {
        guard let declaration = declaration.as(VariableDeclSyntax.self) else {
            throw SpryableDiagnostic.notAVariable
        }

        guard declaration.bindingSpecifier.tokenKind == .keyword(.var) else {
            throw SpryableDiagnostic.onlyApplicableToVar
        }

        guard let name = declaration.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier else {
            throw SpryableDiagnostic.invalidVariableRequirement
        }

        let options = node.varOptions
        var effectSpecifiers: AccessorEffectSpecifiersSyntax?
        if options ~= .async || options ~= .throws {
            effectSpecifiers = .init(asyncSpecifier: options ~= .async ? .keyword(.async) : nil,
                                     throwsClause: options ~= .throws ? .init(throwsSpecifier: .keyword(.throws)) : nil)
        }

        var result: [AccessorDeclSyntax] = []

        if options ~= .set {
            result.append(
                .init(accessorSpecifier: .keyword(.get),
                      effectSpecifiers: effectSpecifiers,
                      body: .init(statements: "return spryify(\"\(raw: name)_get\")"))
            )

            result.append(
                .init(accessorSpecifier: .keyword(.set), body: .init(statements: "return spryify(\"\(raw: name)_set\")"))
            )
        } else if let effectSpecifiers {
            result.append(
                .init(accessorSpecifier: .keyword(.get),
                      effectSpecifiers: effectSpecifiers,
                      body: .init(statements: "return spryify()"))
            )
        } else {
            result.append(
                .init(accessorSpecifier: .keyword(.get),
                      body: .init(statements: "return spryify()"))
            )
        }

        return result
    }
}
#endif
