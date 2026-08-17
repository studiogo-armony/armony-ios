// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage001",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage001", targets: ["BenchPackage001"])
    ],
    targets: [
        .target(name: "BenchPackage001")
    ]
)
