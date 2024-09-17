// swift-tools-version:6.0
// swiftformat:disable all
import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "SpryKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v11),
        .macCatalyst(.v13),
        .tvOS(.v13),
        .watchOS(.v5),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "SpryKit", targets: ["SpryKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/mattgallagher/CwlPreconditionTesting.git", .upToNextMinor(from: "2.2.2")),
        .package(url: "https://github.com/apple/swift-syntax.git", exact: "600.0.0")
    ],
    targets: [
        .target(name: "SpryMacroAvailable",
                path: "VersionMarkerModule"),
        // internal
        .target(name: "SharedTypes",
                dependencies: [
                    .product(name: "SwiftSyntax", package: "swift-syntax"),
                    .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                    .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                    .product(name: "SwiftDiagnostics", package: "swift-syntax"),
                ],
                path: "SharedTypes"),
        .macro(name: "MacroAndCompilerPlugin",
               dependencies: [
                    "SharedTypes",
                    .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                    .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
               ],
               path: "MacroAndCompilerPlugin"),
        // public
        .target(name: "SpryKit",
                dependencies: [
                    "SpryMacroAvailable",
                    "SharedTypes",
                    "MacroAndCompilerPlugin",
                    "CwlPreconditionTesting",
                    .product(name: "SwiftSyntax", package: "swift-syntax")
                ],
                path: "Source",
                resources: [
                    .copy("../PrivacyInfo.xcprivacy")
                ]),
        // test
        .testTarget(name: "SpryKitTests",
                    dependencies: [
                        "SpryKit",
                        .product(name: "SwiftSyntax", package: "swift-syntax"),
                        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                        .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
                    ],
                    path: "Tests")
    ]
)
