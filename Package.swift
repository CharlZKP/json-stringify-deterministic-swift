// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "JSONStringifyDeterministic",
    version: "1.0.0",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .linux],
    products: [
        .library(
            name: "JSONStringifyDeterministic",
            targets: ["JSONStringifyDeterministic"]),
        .executable(
            name: "json-stringify",
            targets: ["json-stringify"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "JSONStringifyDeterministic",
            dependencies: []),
        .executableTarget(
            name: "json-stringify",
            dependencies: ["JSONStringifyDeterministic"]),
        .testTarget(
            name: "JSONStringifyDeterministicTests",
            dependencies: ["JSONStringifyDeterministic"]),
    ]
)
