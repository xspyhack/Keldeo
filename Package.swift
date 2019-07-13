// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Keldeo",
    platforms: [
       .macOS(.v10_14),
       .iOS(.v11),
    ],
    products: [
        .library(
            name: "Keldeo",
            targets: ["Keldeo"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Keldeo",
            dependencies: []),
        .testTarget(
            name: "KeldeoTests",
            dependencies: ["Keldeo"]),
    ]
)
