// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage070",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage070", targets: ["BenchPackage070"])
    ],
    targets: [
        .target(name: "BenchPackage070")
    ]
)
