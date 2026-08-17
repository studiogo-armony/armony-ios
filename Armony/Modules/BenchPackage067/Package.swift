// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage067",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage067", targets: ["BenchPackage067"])
    ],
    targets: [
        .target(name: "BenchPackage067")
    ]
)
