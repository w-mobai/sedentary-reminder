// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MoveEase",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "MoveEase", targets: ["MoveEase"])
    ],
    targets: [
        .executableTarget(
            name: "MoveEase",
            path: "Sources/MoveEase"
        )
    ]
)
