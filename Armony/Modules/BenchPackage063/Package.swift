// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage063",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage063", targets: ["BenchPackage063"])
    ],
    targets: [
        .target(name: "BenchPackage063")
    ]
)
