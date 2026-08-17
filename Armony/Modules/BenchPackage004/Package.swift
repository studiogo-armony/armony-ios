// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage004",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage004", targets: ["BenchPackage004"])
    ],
    targets: [
        .target(name: "BenchPackage004")
    ]
)
