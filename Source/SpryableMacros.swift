#if canImport(SwiftSyntax600) && swift(>=6.0)
import Foundation
import SharedTypes

@attached(extension, names: arbitrary, conformances: Spryable)
public macro Spryable() =
    #externalMacro(module: "MacroAndCompilerPlugin", type: "SpryableExtensionMacro")

@attached(accessor)
public macro SpryableVar(_ accessors: SharedTypes.VarKeyword... = [.get]) =
    #externalMacro(module: "MacroAndCompilerPlugin", type: "SpryableAccessorMacro")

@attached(body)
public macro SpryableFunc(_ accessors: SharedTypes.FuncKeyword... = [.asRealClosure]) =
    #externalMacro(module: "MacroAndCompilerPlugin", type: "SpryableBodyMacro")
#endif
