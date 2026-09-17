// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "libark",
    products: [
        .library(
            name: "libark",
            targets: ["libark"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-system.git", from: "1.3.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
    ],
    targets: [
        .target(
            name: "libark",
            dependencies: [
                .product(name: "SystemPackage", package: "swift-system"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]),
        .testTarget(
            name: "libarkTests",
            dependencies: ["libark"]
        ),
    ]
)
