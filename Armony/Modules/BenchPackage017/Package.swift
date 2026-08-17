// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage017",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage017", targets: ["BenchPackage017"])
    ],
    targets: [
        .target(name: "BenchPackage017")
    ]
)
