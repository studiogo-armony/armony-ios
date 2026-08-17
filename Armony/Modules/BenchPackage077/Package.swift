// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage077",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage077", targets: ["BenchPackage077"])
    ],
    targets: [
        .target(name: "BenchPackage077")
    ]
)
