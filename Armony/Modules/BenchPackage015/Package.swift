// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage015",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage015", targets: ["BenchPackage015"])
    ],
    targets: [
        .target(name: "BenchPackage015")
    ]
)
