// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage039",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage039", targets: ["BenchPackage039"])
    ],
    targets: [
        .target(name: "BenchPackage039")
    ]
)
