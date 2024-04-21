#if canImport(SwiftSyntax600) && swift(>=6.0)
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct MacroAndCompilerPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        SpryableAccessorMacro.self,
        SpryableExtensionMacro.self,
        SpryableBodyMacro.self,
        SpryablePeerMacro.self
    ]
}
#endif
