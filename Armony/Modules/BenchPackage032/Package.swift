// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage032",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage032", targets: ["BenchPackage032"])
    ],
    targets: [
        .target(name: "BenchPackage032")
    ]
)
