// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage014",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage014", targets: ["BenchPackage014"])
    ],
    targets: [
        .target(name: "BenchPackage014")
    ]
)
