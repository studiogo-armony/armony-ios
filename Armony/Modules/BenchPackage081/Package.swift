// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage081",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage081", targets: ["BenchPackage081"])
    ],
    targets: [
        .target(name: "BenchPackage081")
    ]
)
