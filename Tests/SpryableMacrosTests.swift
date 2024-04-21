#if os(macOS) && canImport(SwiftSyntax600)
import MacroAndCompilerPlugin
import SpryKit
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class SpryableMacrosTests: XCTestCase {
    private let sut: [String: Macro.Type] = [
        "SpryableAccessorMacro": SpryableAccessorMacro.self,
        "SpryableExtensionMacro": SpryablePeerMacro.self,
        "SpryableBodyMacro": SpryableBodyMacro.self,
        "SpryablePeerMacro": SpryablePeerMacro.self
    ]

    func testEmptyMacro() {
        let declaration =
            """
            @SpryablePeerMacro
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

    func testStaticMacro() {
        let declaration =
            """
            @SpryablePeerMacro
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
                        return spryify("barSet_set")
                    }
                }
                static static var barAsyncThrows: Int {
                    get async throws {
                        return spryify()
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
                    return spryify(arguments: arg0, arg1)
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

    func testComplexPeerMacro() {
        let declaration =
            """
            @SpryablePeerMacro
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
                        return spryify("barSet_set")
                    }
                }
                public static var barThrows: Int {
                    get throws {
                        return spryify("barThrows_get")
                    }
                    set {
                        return spryify("barThrows_set")
                    }
                }
                var barAsyncThrows: Int {
                    get async throws {
                        return spryify()
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
                    return spryify(arguments: arg0)
                }
                func bazArg5(_: Int, _: String) async -> Int {
                    return spryify(arguments: arg0, arg1)
                }
                static func bazArg6(_: Int, _: String) async throws -> Int {
                    return spryify(arguments: arg0, arg1)
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

    func testComplexExtensionMacro() {
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
                        return spryify("barSet_set")
                    }
                }
                public static var barThrows: Int {
                    get throws {
                        return spryify("barThrows_get")
                    }
                    set {
                        return spryify("barThrows_set")
                    }
                }
                var barAsyncThrows: Int {
                    get async throws {
                        return spryify()
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
                    return spryify(arguments: arg0)
                }
                func bazArg5(_: Int, _: String) async -> Int {
                    return spryify(arguments: arg0, arg1)
                }
                static func bazArg6(_: Int, _: String) async throws -> Int {
                    return spryify(arguments: arg0, arg1)
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
}
#endif
