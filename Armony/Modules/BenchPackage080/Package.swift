// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage080",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage080", targets: ["BenchPackage080"])
    ],
    targets: [
        .target(name: "BenchPackage080")
    ]
)
