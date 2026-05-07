// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CanvasBridgeCore",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "CanvasBridgeCore",
            targets: ["CanvasBridgeCore"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CanvasBridgeCore",
            dependencies: []),
    ]
)
