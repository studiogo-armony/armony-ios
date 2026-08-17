// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage084",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage084", targets: ["BenchPackage084"])
    ],
    targets: [
        .target(name: "BenchPackage084")
    ]
)
