// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage011",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage011", targets: ["BenchPackage011"])
    ],
    targets: [
        .target(name: "BenchPackage011")
    ]
)
