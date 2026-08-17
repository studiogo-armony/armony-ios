// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage028",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage028", targets: ["BenchPackage028"])
    ],
    targets: [
        .target(name: "BenchPackage028")
    ]
)
