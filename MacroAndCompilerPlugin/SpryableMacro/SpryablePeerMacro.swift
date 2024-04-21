#if canImport(SwiftSyntax600) && swift(>=6.0)
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public enum SpryablePeerMacro: PeerMacro {
    public static func expansion(of node: AttributeSyntax,
                                 providingPeersOf declaration: some DeclSyntaxProtocol,
                                 in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        guard let declaration = declaration.as(ClassDeclSyntax.self) else {
            throw SpryableDiagnostic.onlyApplicableToClass
        }

        let type: TypeSyntaxProtocol = TypeSyntax(IdentifierTypeSyntax(name: declaration.name.trimmed))

        let decl = try ExtensionDeclSyntax(extendedType: type, inheritanceClause: .init(inheritedTypes: [.init(type: IdentifierTypeSyntax(name: "Spryable"))]), memberBlockBuilder: {
            let requirements = try MembersParser(declaration)
            try enumBlockBuilder(requirements, isStatic: true).with(\.trailingTrivia, .newline)
            try enumBlockBuilder(requirements, isStatic: false).with(\.trailingTrivia, .newline)
            //                try initBlockBuilder(modifiers: requirements.syntax.modifiers)
        })
        return [
            .init(decl)
        ]
    }
}
#endif
