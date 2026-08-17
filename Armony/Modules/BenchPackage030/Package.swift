// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage030",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage030", targets: ["BenchPackage030"])
    ],
    targets: [
        .target(name: "BenchPackage030")
    ]
)
