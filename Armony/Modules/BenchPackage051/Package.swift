// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage051",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage051", targets: ["BenchPackage051"])
    ],
    targets: [
        .target(name: "BenchPackage051")
    ]
)
