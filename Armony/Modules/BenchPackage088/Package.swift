// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage088",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage088", targets: ["BenchPackage088"])
    ],
    targets: [
        .target(name: "BenchPackage088")
    ]
)
