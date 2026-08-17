// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage064",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage064", targets: ["BenchPackage064"])
    ],
    targets: [
        .target(name: "BenchPackage064")
    ]
)
