#if os(macOS) && canImport(SwiftSyntax600) && canImport(Testing)
import SpryKit
import SwiftSyntax
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros
import SwiftSyntaxMacrosGenericTestSupport
import Testing
@testable import MacroAndCompilerPlugin

private func assertMacroExpansion(_ originalSource: String,
                                  expandedSource: String,
                                  diagnostics: [DiagnosticSpec] = [],
                                  macros: [String: Macro.Type],
                                  sourceLocation: Testing.SourceLocation = #_sourceLocation) {
    SwiftSyntaxMacrosGenericTestSupport.assertMacroExpansion(originalSource,
                                                             expandedSource: expandedSource,
                                                             diagnostics: diagnostics,
                                                             macroSpecs: macros.mapValues { MacroSpec(type: $0) },
                                                             failureHandler: { failure in
                                                                 Issue.record("\(failure.message)", sourceLocation: sourceLocation)
                                                             })
}

@Suite("SpryableMacros Tests", .serialized)
struct SpryableMacrosTests {
    private let sut: [String: Macro.Type] = [
        "SpryableAccessorMacro": SpryableAccessorMacro.self,
        "SpryableExtensionMacro": SpryableExtensionMacro.self,
        "SpryableBodyMacro": SpryableBodyMacro.self
    ]

    @Test("Empty macro")
    func emptyMacro() {
        let declaration =
            """
            @SpryableExtensionMacro
            public final class FakeFoo {
            }
            """

        let expected =
            """

            public final class FakeFoo {
            }

            extension FakeFoo: Spryable {
                public enum ClassFunction: String, StringRepresentable {
                    case _unknown_ = "'enum' must have at least one 'case'"
                }

                public enum Function: String, StringRepresentable {
                    case _unknown_ = "'enum' must have at least one 'case'"
                }
            }
            """

        assertMacroExpansion(declaration,
                             expandedSource: expected,
                             macros: sut)
    }

    @Test("Nonamed args")
    func nonamedArgs() {
        let declaration =
            """
            @SpryableExtensionMacro
            final class FakeFoo {
                @SpryableBodyMacro
                func bazArg3(some: Int, _: Int, _ some2: Int)
            }
            """

        let expected =
            """

            final class FakeFoo {
                func bazArg3(some: Int, _: Int, _ some2: Int) {
                    return spryify(arguments: some, Argument.skipped, some2)
                }
            }

            extension FakeFoo: Spryable {
                enum ClassFunction: String, StringRepresentable {
                    case _unknown_ = "'enum' must have at least one 'case'"
                }
                enum Function: String, StringRepresentable {
                    case bazArg3WithSome_Arg1_Some2 = "bazArg3(some:_:_:)"
                }
            }
            """

        assertMacroExpansion(declaration,
                             expandedSource: expected,
                             macros: sut)
    }

    @Test("Static macro")
    func staticMacro() {
        let declaration =
            """
            @SpryableExtensionMacro
            public final class FakeFoo: Foo, Foo2 {
                @SpryableAccessorMacro
                public static var bar: Int

                @SpryableAccessorMacro(.set)
                public static var barSet: Int

                @SpryableAccessorMacro(.throws, .async)
                static static var barAsyncThrows: Int

                @SpryableBodyMacro
                public static func baz()

                @SpryableBodyMacro
                public static func bazArg(some: Int)

                @SpryableBodyMacro
                public static func bazArg2(some: Int, some2: Int)

                @SpryableBodyMacro
                public static func bazArg3(some: Int, _ some2: Int)

                @SpryableBodyMacro
                static func bazArg6(_: Int, _: String) async throws -> Int
            }
            """

        let expected =
            """
            public final class FakeFoo: Foo, Foo2 {
                public static var bar: Int {
                    get {
                        return spryify()
                    }
                }
                public static var barSet: Int {
                    get {
                        return spryify("barSet_get")
                    }
                    set {
                        return spryify("barSet_set", arguments: newValue)
                    }
                }
                static static var barAsyncThrows: Int {
                    get async throws {
                        return try spryifyThrows()
                    }
                }
                public static func baz() {
                    return spryify()
                }
                public static func bazArg(some: Int) {
                    return spryify(arguments: some)
                }
                public static func bazArg2(some: Int, some2: Int) {
                    return spryify(arguments: some, some2)
                }
                public static func bazArg3(some: Int, _ some2: Int) {
                    return spryify(arguments: some, some2)
                }
                static func bazArg6(_: Int, _: String) async throws -> Int {
                    return try spryifyThrows(arguments: Argument.skipped, Argument.skipped)
                }
            }

            extension FakeFoo: Spryable {
                public enum ClassFunction: String, StringRepresentable {
                    case bar
                    case barSet_get = "barSet_get"
                    case barSet_set = "barSet_set"
                    case barAsyncThrows
                    case baz = "baz()"
                    case bazArgWithSome = "bazArg(some:)"
                    case bazArg2WithSome_Some2 = "bazArg2(some:some2:)"
                    case bazArg3WithSome_Some2 = "bazArg3(some:_:)"
                    case bazArg6WithArg0_Arg1 = "bazArg6(_:_:)"
                }

                public enum Function: String, StringRepresentable {
                    case _unknown_ = "'enum' must have at least one 'case'"
                }
            }
            """

        assertMacroExpansion(declaration,
                             expandedSource: expected,
                             macros: sut)
    }

    @Test("Complex extension macro")
    func complexExtensionMacro() {
        let declaration =
            """
            @SpryableExtensionMacro
            public final class FakeFoo: Foo, Foo2 {
                @SpryableAccessorMacro
                public var bar: Int

                @SpryableAccessorMacro(.set)
                public var barSet: Int

                @SpryableAccessorMacro(.set, .throws)
                public static var barThrows: Int

                @SpryableAccessorMacro(.throws, .async)
                var barAsyncThrows: Int

                @SpryableBodyMacro
                public func baz()

                @SpryableBodyMacro
                public func bazArg(some: Int)

                @SpryableBodyMacro
                public static func bazArg2(some: Int, some2: Int)

                @SpryableBodyMacro
                public func bazArg3(some: Int, _ some2: Int)

                @SpryableBodyMacro
                public func bazArg4(_: Int)

                @SpryableBodyMacro
                func bazArg5(_: Int, _: String) async -> Int

                @SpryableBodyMacro
                static func bazArg6(_: Int, _: String) async throws -> Int
            }
            """

        let expected =
            """

            public final class FakeFoo: Foo, Foo2 {
                public var bar: Int {
                    get {
                        return spryify()
                    }
                }
                public var barSet: Int {
                    get {
                        return spryify("barSet_get")
                    }
                    set {
                        return spryify("barSet_set", arguments: newValue)
                    }
                }
                public static var barThrows: Int {
                    get throws {
                        return try spryifyThrows("barThrows_get")
                    }
                    set {
                        return spryify("barThrows_set", arguments: newValue)
                    }
                }
                var barAsyncThrows: Int {
                    get async throws {
                        return try spryifyThrows()
                    }
                }
                public func baz() {
                    return spryify()
                }
                public func bazArg(some: Int) {
                    return spryify(arguments: some)
                }
                public static func bazArg2(some: Int, some2: Int) {
                    return spryify(arguments: some, some2)
                }
                public func bazArg3(some: Int, _ some2: Int) {
                    return spryify(arguments: some, some2)
                }
                public func bazArg4(_: Int) {
                    return spryify(arguments: Argument.skipped)
                }
                func bazArg5(_: Int, _: String) async -> Int {
                    return spryify(arguments: Argument.skipped, Argument.skipped)
                }
                static func bazArg6(_: Int, _: String) async throws -> Int {
                    return try spryifyThrows(arguments: Argument.skipped, Argument.skipped)
                }
            }

            extension FakeFoo: Spryable {
                public enum ClassFunction: String, StringRepresentable {
                    case barThrows_get = "barThrows_get"
                    case barThrows_set = "barThrows_set"
                    case bazArg2WithSome_Some2 = "bazArg2(some:some2:)"
                    case bazArg6WithArg0_Arg1 = "bazArg6(_:_:)"
                }

                public enum Function: String, StringRepresentable {
                    case bar
                    case barSet_get = "barSet_get"
                    case barSet_set = "barSet_set"
                    case barAsyncThrows
                    case baz = "baz()"
                    case bazArgWithSome = "bazArg(some:)"
                    case bazArg3WithSome_Some2 = "bazArg3(some:_:)"
                    case bazArg4WithArg0 = "bazArg4(_:)"
                    case bazArg5WithArg0_Arg1 = "bazArg5(_:_:)"
                }
            }
            """

        assertMacroExpansion(declaration,
                             expandedSource: expected,
                             macros: sut)
    }

    @Test("Effects, access control and closure arguments")
    func effects() {
        let declaration =
            """
            @SpryableExtensionMacro
            final class FakeFoo {
                private var hidden: Int
                private func hiddenFunc()

                @SpryableAccessorMacro(.throws)
                var throwing: Int

                @SpryableBodyMacro
                func plainThrows(some: Int) throws -> Int

                @SpryableBodyMacro
                func rethrowing<R>(execute work: @escaping () throws -> R) rethrows -> R

                @SpryableBodyMacro(.asArgument)
                func withClosures(first: @escaping () -> Void, second: @escaping () -> Void, third: Int)

                @SpryableBodyMacro
                class func classScoped(some: Int)
            }
            """

        let expected =
            """

            final class FakeFoo {
                private var hidden: Int
                private func hiddenFunc()
                var throwing: Int {
                    get throws {
                        return try spryifyThrows()
                    }
                }
                func plainThrows(some: Int) throws -> Int {
                    return try spryifyThrows(arguments: some)
                }
                func rethrowing<R>(execute work: @escaping () throws -> R) rethrows -> R {
                    return spryify(arguments: work)
                }
                func withClosures(first: @escaping () -> Void, second: @escaping () -> Void, third: Int) {
                    return spryify(arguments: Argument.closure, Argument.closure, third)
                }
                class func classScoped(some: Int) {
                    return spryify(arguments: some)
                }
            }

            extension FakeFoo: Spryable {
                enum ClassFunction: String, StringRepresentable {
                    case classScopedWithSome = "classScoped(some:)"
                }
                enum Function: String, StringRepresentable {
                    case throwing
                    case plainThrowsWithSome = "plainThrows(some:)"
                    case rethrowingWithExecute = "rethrowing(execute:)"
                    case withClosuresWithFirst_Second_Third = "withClosures(first:second:third:)"
                }
            }
            """

        assertMacroExpansion(declaration,
                             expandedSource: expected,
                             macros: sut)
    }

    @Test("Typed throws is rejected")
    func typedThrows() {
        let declaration =
            """
            @SpryableExtensionMacro
            final class FakeFoo {
                @SpryableBodyMacro
                func typed() throws(CancellationError) -> Int
            }
            """

        let expected =
            """

            final class FakeFoo {
                func typed() throws(CancellationError) -> Int
            }

            extension FakeFoo: Spryable {
                enum ClassFunction: String, StringRepresentable {
                    case _unknown_ = "'enum' must have at least one 'case'"
                }
                enum Function: String, StringRepresentable {
                    case typed = "typed()"
                }
            }
            """

        assertMacroExpansion(declaration,
                             expandedSource: expected,
                             diagnostics: [
                                 .init(message: SpryableDiagnostic.typedThrowsNotSupported.message,
                                       line: 3,
                                       column: 5)
                             ],
                             macros: sut)
    }

    @Test("Duplicate generated case name is rejected")
    func duplicateCaseName() {
        let declaration =
            """
            @SpryableExtensionMacro
            final class FakeFoo {
                @SpryableAccessorMacro
                var value: Int

                @SpryableBodyMacro
                func value()
            }
            """

        let expected =
            """

            final class FakeFoo {
                var value: Int {
                    get {
                        return spryify()
                    }
                }
                func value() {
                    return spryify()
                }
            }
            """

        assertMacroExpansion(declaration,
                             expandedSource: expected,
                             diagnostics: [
                                 .init(message: SpryableDiagnostic.duplicateCaseName("value").message,
                                       line: 1,
                                       column: 1)
                             ],
                             macros: sut)
    }

    @Test("A struct is rejected")
    func a_struct_is_rejected() {
        assertMacroExpansion("""
                             @SpryableExtensionMacro
                             struct FakeFoo {
                             }
                             """,
                             expandedSource: """
                             struct FakeFoo {
                             }
                             """,
                             diagnostics: [
                                 .init(message: SpryableDiagnostic.onlyApplicableToClass.message,
                                       line: 1,
                                       column: 1)
                             ],
                             macros: sut)
    }

    @Test("A subscript is rejected")
    func a_subscript_is_rejected() {
        assertMacroExpansion("""
                             @SpryableExtensionMacro
                             final class FakeFoo {
                                 subscript(index: Int) -> Int
                             }
                             """,
                             expandedSource: """
                             final class FakeFoo {
                                 subscript(index: Int) -> Int
                             }
                             """,
                             diagnostics: [
                                 .init(message: SpryableDiagnostic.subscriptsNotSupported.message,
                                       line: 1,
                                       column: 1)
                             ],
                             macros: sut)
    }

    @Test("An operator is rejected")
    func an_operator_is_rejected() {
        assertMacroExpansion("""
                             @SpryableExtensionMacro
                             final class FakeFoo {
                                 static func ==(lhs: FakeFoo, rhs: FakeFoo) -> Bool
                             }
                             """,
                             expandedSource: """
                             final class FakeFoo {
                                 static func ==(lhs: FakeFoo, rhs: FakeFoo) -> Bool
                             }
                             """,
                             diagnostics: [
                                 .init(message: SpryableDiagnostic.operatorsNotSupported.message,
                                       line: 1,
                                       column: 1)
                             ],
                             macros: sut)
    }

    @Test("A let property is rejected")
    func a_let_property_is_rejected() {
        assertMacroExpansion("""
                             final class FakeFoo {
                                 @SpryableAccessorMacro
                                 let value: Int
                             }
                             """,
                             expandedSource: """
                             final class FakeFoo {
                                 let value: Int
                             }
                             """,
                             diagnostics: [
                                 .init(message: SpryableDiagnostic.onlyApplicableToVar.message,
                                       line: 2,
                                       column: 5)
                             ],
                             macros: sut)
    }

    @Test("Closures")
    func closures() {
        let declaration =
            """
            @SpryableExtensionMacro
            final class FakeClosures {
                @SpryableBodyMacro
                func sync<R>(execute work: () throws -> R) rethrows -> R

                @SpryableBodyMacro
                func escaping<R>(execute work: @escaping () throws -> R) rethrows -> R
            }
            """

        let expected =
            """
            final class FakeClosures {
                func sync<R>(execute work: () throws -> R) rethrows -> R
                func escaping<R>(execute work: @escaping () throws -> R) rethrows -> R {
                    return spryify(arguments: work)
                }
            }

            extension FakeClosures: Spryable {
                enum ClassFunction: String, StringRepresentable {
                    case _unknown_ = "'enum' must have at least one 'case'"
                }
                enum Function: String, StringRepresentable {
                    case syncWithExecute = "sync(execute:)"
                    case escapingWithExecute = "escaping(execute:)"
                }
            }
            """

        assertMacroExpansion(declaration,
                             expandedSource: expected,
                             diagnostics: [
                                 .init(message: SpryableDiagnostic.nonEscapingClosureNotSupported.message,
                                       line: 3,
                                       column: 5)
                             ],
                             macros: sut)
    }
}
#endif // canImport(Testing)
