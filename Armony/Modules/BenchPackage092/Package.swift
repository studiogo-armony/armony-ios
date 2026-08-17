// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage092",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage092", targets: ["BenchPackage092"])
    ],
    targets: [
        .target(name: "BenchPackage092")
    ]
)
