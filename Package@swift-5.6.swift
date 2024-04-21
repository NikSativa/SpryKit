// swift-tools-version:5.6
// swiftformat:disable all
import PackageDescription

let package = Package(
    name: "SpryKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v11),
        .macCatalyst(.v13),
        .tvOS(.v13),
        .watchOS(.v5)
    ],
    products: [
        .library(name: "SpryKit", targets: ["SpryKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/mattgallagher/CwlPreconditionTesting.git", .upToNextMinor(from: "2.2.2"))
    ],
    targets: [
        .target(name: "SpryKit",
                dependencies: [
                    "CwlPreconditionTesting"
                ],
                path: "Source",
                resources: [
                    .copy("../PrivacyInfo.xcprivacy")
                ]),
        .testTarget(name: "SpryTests",
                    dependencies: [
                        "SpryKit"
                    ],
                    path: "Tests")
    ]
)
