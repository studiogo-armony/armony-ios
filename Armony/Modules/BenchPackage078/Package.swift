// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage078",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage078", targets: ["BenchPackage078"])
    ],
    targets: [
        .target(name: "BenchPackage078")
    ]
)
