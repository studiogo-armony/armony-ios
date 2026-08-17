// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage003",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage003", targets: ["BenchPackage003"])
    ],
    targets: [
        .target(name: "BenchPackage003")
    ]
)
