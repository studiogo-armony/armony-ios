// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage002",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage002", targets: ["BenchPackage002"])
    ],
    targets: [
        .target(name: "BenchPackage002")
    ]
)
