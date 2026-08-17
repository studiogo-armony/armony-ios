// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage005",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage005", targets: ["BenchPackage005"])
    ],
    targets: [
        .target(name: "BenchPackage005")
    ]
)
