// swift-tools-version:6.0
// swiftformat:disable all
import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "SpryKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v14),
        .macCatalyst(.v15),
        .tvOS(.v16),
        .watchOS(.v9),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "SpryKit", targets: ["SpryKit"]),
        .library(name: "SpryKitStatic", type: .static, targets: ["SpryKit"]),
        .library(name: "SpryKitDynamic", type: .dynamic, targets: ["SpryKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/NikSativa/Threading.git", from: "2.3.4"),
        .package(url: "https://github.com/mattgallagher/CwlPreconditionTesting.git", from: "2.2.2"),
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.1")
    ],
    targets: [
        .target(name: "SpryMacroAvailable",
                path: "VersionMarkerModule"),
        // internal
        .target(name: "SharedTypes",
                path: "SharedTypes"),
        .macro(name: "MacroAndCompilerPlugin",
               dependencies: [
                    "SharedTypes",
                    .product(name: "SwiftSyntax", package: "swift-syntax"),
                    .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                    .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                    .product(name: "SwiftDiagnostics", package: "swift-syntax"),
                    .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
               ],
               path: "MacroAndCompilerPlugin"),
        // public
        .target(name: "SpryKit",
                dependencies: [
                    "SpryMacroAvailable",
                    "SharedTypes",
                    "MacroAndCompilerPlugin",
                    .product(name: "CwlPreconditionTesting", package: "CwlPreconditionTesting", condition: .when(platforms: [.iOS, .macOS, .macCatalyst, .tvOS, .watchOS, .visionOS])),
                    "Threading"
                ],
                path: "Source",
                resources: [
                    .process("PrivacyInfo.xcprivacy")
                ]),
        // test
        .testTarget(name: "SpryKitTests",
                    dependencies: [
                        "SpryKit",
                        "MacroAndCompilerPlugin",
                        .product(name: "SwiftSyntax", package: "swift-syntax"),
                        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                        .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                        .product(name: "SwiftSyntaxMacrosGenericTestSupport", package: "swift-syntax"),
                        .product(name: "SwiftSyntaxMacroExpansion", package: "swift-syntax")
                    ],
                    path: "Tests")
    ]
)
