// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage045",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage045", targets: ["BenchPackage045"])
    ],
    targets: [
        .target(name: "BenchPackage045")
    ]
)
