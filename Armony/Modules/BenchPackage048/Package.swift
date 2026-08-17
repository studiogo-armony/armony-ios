// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage048",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage048", targets: ["BenchPackage048"])
    ],
    targets: [
        .target(name: "BenchPackage048")
    ]
)
