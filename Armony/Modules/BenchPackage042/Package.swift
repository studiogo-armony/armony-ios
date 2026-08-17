// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage042",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage042", targets: ["BenchPackage042"])
    ],
    targets: [
        .target(name: "BenchPackage042")
    ]
)
