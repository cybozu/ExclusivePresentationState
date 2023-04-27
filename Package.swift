// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ExclusivePresentationState",
    platforms: [
        .iOS(.v15),
        .tvOS(.v15),
        .watchOS(.v8),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "ExclusivePresentationState",
            targets: ["ExclusivePresentationState"]
        ),
    ],
    targets: [
        .target(
            name: "ExclusivePresentationState",
            path: "Sources"
        ),
        .testTarget(
            name: "ExclusivePresentationStateTests",
            dependencies: ["ExclusivePresentationState"],
            path: "Tests"
        ),
    ]
)
