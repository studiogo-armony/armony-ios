// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage062",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage062", targets: ["BenchPackage062"])
    ],
    targets: [
        .target(name: "BenchPackage062")
    ]
)
