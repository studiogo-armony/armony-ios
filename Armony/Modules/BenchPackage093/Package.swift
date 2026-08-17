// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage093",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage093", targets: ["BenchPackage093"])
    ],
    targets: [
        .target(name: "BenchPackage093")
    ]
)
