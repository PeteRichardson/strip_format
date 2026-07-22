// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "StripFormat",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "StripFormat",
            path: "Sources/StripFormat"
        ),
        .testTarget(
            name: "StripFormatTests",
            dependencies: ["StripFormat"],
            path: "Tests/StripFormatTests"
        )
    ]
)
