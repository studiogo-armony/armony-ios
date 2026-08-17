// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage009",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage009", targets: ["BenchPackage009"])
    ],
    targets: [
        .target(name: "BenchPackage009")
    ]
)
