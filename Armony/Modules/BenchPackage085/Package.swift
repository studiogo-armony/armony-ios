// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage085",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage085", targets: ["BenchPackage085"])
    ],
    targets: [
        .target(name: "BenchPackage085")
    ]
)
