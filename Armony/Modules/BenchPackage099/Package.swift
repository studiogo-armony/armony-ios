// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage099",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage099", targets: ["BenchPackage099"])
    ],
    targets: [
        .target(name: "BenchPackage099")
    ]
)
