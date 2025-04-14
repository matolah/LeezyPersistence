// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LeezyPersistence",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "LeezyPersistence", targets: ["LeezyPersistence"])
    ],
    targets: [
        .target(
            name: "LeezyPersistence",
            path: "Sources"
        ),
        .testTarget(
            name: "LeezyPersistenceTests",
            dependencies: ["LeezyPersistence"],
            path: "Tests"
        )
    ]
)
