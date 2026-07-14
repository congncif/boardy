// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BoardySmoke",
    platforms: [.iOS(.v14)],
    products: [
        .library(name: "BoardySmoke", targets: ["BoardySmoke"])
    ],
    dependencies: [
        .package(path: "../..")
    ],
    targets: [
        .target(
            name: "BoardySmoke",
            dependencies: [
                .product(name: "Boardy", package: "boardy")
            ],
            path: "Sources/BoardySmoke"
        )
    ],
    swiftLanguageVersions: [.v5]
)
