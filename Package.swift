// swift-tools-version:5.4

import PackageDescription

let package = Package(name: "NSpry",
                      platforms: [.iOS(.v10)],
                      products: [.library(name: "NSpry", targets: ["NSpry"])],
                      dependencies: [.package(url: "https://github.com/Quick/Quick.git", .upToNextMajor(from: "4.0.0")),
                                     .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "9.2.0"))],
                      targets: [.target(name: "NSpry",
                                        dependencies: ["Nimble"],
                                        path: "Source"),
                                .testTarget(name: "NSpryTests",
                                            dependencies: ["NSpry",
                                                           "Nimble",
                                                           "Quick"],
                                            path: "Tests")],
                      swiftLanguageVersions: [.v5])
