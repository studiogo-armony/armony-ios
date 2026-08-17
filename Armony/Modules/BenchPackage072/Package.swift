// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage072",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage072", targets: ["BenchPackage072"])
    ],
    targets: [
        .target(name: "BenchPackage072")
    ]
)
