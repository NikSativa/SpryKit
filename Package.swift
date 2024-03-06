// swift-tools-version:5.9
// swiftformat:disable all
import PackageDescription

let package = Package(
    name: "NSpry",
    platforms: [
        .iOS(.v13),
        .macOS(.v11),
        .macCatalyst(.v13)
    ],
    products: [
        .library(name: "NSpry", targets: ["NSpry"]),
    ],
    dependencies: [
        .package(url: "https://github.com/mattgallagher/CwlPreconditionTesting.git", .upToNextMinor(from: "2.2.1"))
    ],
    targets: [
        .target(name: "NSpry",
                dependencies: [
                    "CwlPreconditionTesting"
                ],
                path: "Source"),
        .testTarget(name: "NSpryTests",
                    dependencies: [
                        "NSpry"
                    ],
                    path: "Tests")
    ]
)
