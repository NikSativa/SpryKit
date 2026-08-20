#if canImport(SwiftSyntax600)
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct MacroAndCompilerPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        SpryableAccessorMacro.self,
        SpryableExtensionMacro.self,
        SpryableBodyMacro.self
    ]
}
#endif
