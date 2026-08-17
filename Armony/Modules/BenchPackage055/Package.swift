// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage055",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage055", targets: ["BenchPackage055"])
    ],
    targets: [
        .target(name: "BenchPackage055")
    ]
)
