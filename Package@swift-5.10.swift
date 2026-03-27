// swift-tools-version:5.10
// swiftformat:disable all
import PackageDescription

let package = Package(
    name: "SpryKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v14),
        .macCatalyst(.v16),
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
        .package(url: "https://github.com/NikSativa/Threading.git", from: "2.2.1"),
        .package(url: "https://github.com/mattgallagher/CwlPreconditionTesting.git", from: "2.2.2")
    ],
    targets: [
        .target(name: "SpryKit",
                dependencies: [
                    "CwlPreconditionTesting",
                    "Threading"
                ],
                path: "Source",
                resources: [
                    .process("PrivacyInfo.xcprivacy")
                ],
                swiftSettings: [
                    .define("supportsVisionOS", .when(platforms: [.visionOS])),
                ]),
        .testTarget(name: "SpryKitTests",
                    dependencies: [
                        "SpryKit"
                    ],
                    path: "Tests",
                    swiftSettings: [
                        .define("supportsVisionOS", .when(platforms: [.visionOS])),
                    ])
    ]
)
