// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage053",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage053", targets: ["BenchPackage053"])
    ],
    targets: [
        .target(name: "BenchPackage053")
    ]
)
