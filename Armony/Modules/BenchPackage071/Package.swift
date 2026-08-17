// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage071",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage071", targets: ["BenchPackage071"])
    ],
    targets: [
        .target(name: "BenchPackage071")
    ]
)
