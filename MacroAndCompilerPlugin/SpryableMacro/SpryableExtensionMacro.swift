#if canImport(SwiftSyntax600) && swift(>=6.0)
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public enum SpryableExtensionMacro: ExtensionMacro {
    public static func expansion(of node: AttributeSyntax,
                                 attachedTo declaration: some DeclGroupSyntax,
                                 providingExtensionsOf type: some TypeSyntaxProtocol,
                                 conformingTo protocols: [TypeSyntax],
                                 in context: some MacroExpansionContext) throws -> [ExtensionDeclSyntax] {
        guard let declaration = declaration.as(ClassDeclSyntax.self) else {
            throw SpryableDiagnostic.onlyApplicableToClass
        }

        return try [
            .init(extendedType: type,
                  inheritanceClause: .init(inheritedTypes: [.init(type: IdentifierTypeSyntax(name: "Spryable"))]),
                  memberBlockBuilder: {
                      let requirements = try MembersParser(declaration)
                      try enumBlockBuilder(requirements, isStatic: true).with(\.trailingTrivia, .newline)
                      try enumBlockBuilder(requirements, isStatic: false).with(\.trailingTrivia, .newline)
                      //                try initBlockBuilder(modifiers: requirements.syntax.modifiers)
                  })
        ]
    }
}
#endif
