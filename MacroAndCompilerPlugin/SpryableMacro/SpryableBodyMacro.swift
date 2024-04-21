#if canImport(SwiftSyntax600) && swift(>=6.0)
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public enum SpryableBodyMacro: BodyMacro {
    public static func expansion(of node: AttributeSyntax,
                                 providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
                                 in context: some MacroExpansionContext) throws -> [CodeBlockItemSyntax] {
        guard let syntax = declaration as? FunctionDeclSyntax else {
            throw SpryableDiagnostic.notAFunction
        }

        let parameters = syntax.signature.parameterClause.parameters.enumerated().map { idx, param in
            let name = param.secondName ?? param.firstName
            if name.text != TokenSyntax.wildcardToken().text {
                return param
            } else {
                return param.with(\.secondName, .identifier("arg\(idx)"))
            }
        }

        let arguments = LabeledExprListSyntax {
            for (idx, parameter) in parameters.enumerated() {
                let name = parameter.secondName ?? parameter.firstName
                if idx == 0 {
                    LabeledExprSyntax(label: "arguments", expression: DeclReferenceExprSyntax(baseName: name))
                } else {
                    LabeledExprSyntax(expression: DeclReferenceExprSyntax(baseName: name))
                }
            }
        }

        let funcCall = FunctionCallExprSyntax(calledExpression: DeclReferenceExprSyntax(baseName: "spryify"),
                                              leftParen: .leftParenToken(),
                                              arguments: arguments,
                                              rightParen: .rightParenToken())
        let smt = ReturnStmtSyntax(expression: funcCall)

        return [
            .init(item: .stmt(.init(smt)))
        ]
    }
}
#endif
