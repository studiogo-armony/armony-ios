// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage054",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage054", targets: ["BenchPackage054"])
    ],
    targets: [
        .target(name: "BenchPackage054")
    ]
)
