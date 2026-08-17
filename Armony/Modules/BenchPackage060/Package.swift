// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage060",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage060", targets: ["BenchPackage060"])
    ],
    targets: [
        .target(name: "BenchPackage060")
    ]
)
