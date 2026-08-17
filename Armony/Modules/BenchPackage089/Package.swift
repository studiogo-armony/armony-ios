// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage089",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage089", targets: ["BenchPackage089"])
    ],
    targets: [
        .target(name: "BenchPackage089")
    ]
)
