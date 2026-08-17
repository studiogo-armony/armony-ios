// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage040",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage040", targets: ["BenchPackage040"])
    ],
    targets: [
        .target(name: "BenchPackage040")
    ]
)
