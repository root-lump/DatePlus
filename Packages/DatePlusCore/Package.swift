// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "DatePlusCore",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v13),
        .watchOS(.v9),
    ],
    products: [
        .library(name: "DatePlusCore", targets: ["DatePlusCore"]),
    ],
    targets: [
        .target(
            name: "DatePlusCore",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "DatePlusCoreTests",
            dependencies: ["DatePlusCore"]
        ),
    ]
)
