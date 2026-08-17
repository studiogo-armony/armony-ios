// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage037",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage037", targets: ["BenchPackage037"])
    ],
    targets: [
        .target(name: "BenchPackage037")
    ]
)
