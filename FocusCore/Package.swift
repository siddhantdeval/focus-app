// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FocusCore",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "FocusCore",
            targets: ["FocusCore"]),
    ],
    targets: [
        .binaryTarget(
            name: "focus_coreFFI",
            path: "FocusCore.xcframework"
        ),
        .target(
            name: "FocusCore",
            dependencies: ["focus_coreFFI"],
            path: "Sources/FocusCore"
        )
    ]
)
