// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage086",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage086", targets: ["BenchPackage086"])
    ],
    targets: [
        .target(name: "BenchPackage086")
    ]
)
