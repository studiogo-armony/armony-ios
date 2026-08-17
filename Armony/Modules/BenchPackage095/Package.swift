// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage095",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage095", targets: ["BenchPackage095"])
    ],
    targets: [
        .target(name: "BenchPackage095")
    ]
)
