// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage061",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage061", targets: ["BenchPackage061"])
    ],
    targets: [
        .target(name: "BenchPackage061")
    ]
)
