#if canImport(SwiftSyntax600) && swift(>=6.0)
import SwiftSyntax

struct MembersParser {
    let syntax: ClassDeclSyntax
    let functions: [FunctionDeclSyntax]
    let variables: [VariableDeclSyntax]

    init(_ syntax: ClassDeclSyntax) throws {
        self.syntax = syntax

        let members = syntax.memberBlock.members
        var functions: [FunctionDeclSyntax] = []
        var variables: [VariableDeclSyntax] = []
        for member in members {
            if member.decl.is(SubscriptDeclSyntax.self) {
                throw SpryableDiagnostic.subscriptsNotSupported
            } else if let decl = member.decl.as(VariableDeclSyntax.self) {
                variables.append(decl)
            } else if let decl = member.decl.as(FunctionDeclSyntax.self) {
                guard case .identifier = decl.name.tokenKind else {
                    throw SpryableDiagnostic.operatorsNotSupported
                }
                functions.append(decl)
            }
        }

        self.variables = variables
        self.functions = functions
    }
}
#endif
