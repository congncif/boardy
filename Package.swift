// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Boardy",
    platforms: [.iOS(.v14)],
    products: [
        .library(name: "Boardy", targets: ["Boardy"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/congncif/UIComposable.git",
            exact: "1.1.0"
        ),
    ],
    targets: [
        .target(
            name: "Boardy",
            dependencies: [
                .product(
                    name: "UIComposableCore",
                    package: "uicomposable"
                ),
            ],
            path: "Boardy"
        ),
        .testTarget(
            name: "BoardyTests",
            dependencies: ["Boardy"],
            path: "Example/Tests",
            exclude: ["Info.plist"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
