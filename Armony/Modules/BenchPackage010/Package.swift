// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage010",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage010", targets: ["BenchPackage010"])
    ],
    targets: [
        .target(name: "BenchPackage010")
    ]
)
