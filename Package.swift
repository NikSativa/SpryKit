// swift-tools-version:5.2

import PackageDescription

// swiftformat:disable all
let package = Package(
    name: "NSpry",
    platforms: [.iOS(.v10), .macOS(.v10_12)],
    products: [
        .library(name: "NSpry", targets: ["NSpry"]),
        .library(name: "NSpry_Nimble", targets: ["NSpry_Nimble"])
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Quick.git", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "9.2.0"))
    ],
    targets: [
        .target(name: "NSpry",
                dependencies: [],
                path: "Source/Core"),
        .target(name: "NSpry_Nimble",
                dependencies: ["NSpry",
                               "Nimble"],
                path: "Source/Nimble"),
        .testTarget(name: "NSpryTests",
                    dependencies: ["NSpry",
                                   "NSpry_Nimble",
                                   "Nimble",
                                   "Quick"],
                    path: "Tests")
    ]
)
