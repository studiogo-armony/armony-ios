// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage007",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage007", targets: ["BenchPackage007"])
    ],
    targets: [
        .target(name: "BenchPackage007")
    ]
)
