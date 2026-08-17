// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage034",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage034", targets: ["BenchPackage034"])
    ],
    targets: [
        .target(name: "BenchPackage034")
    ]
)
