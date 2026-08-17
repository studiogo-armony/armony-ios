// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage035",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage035", targets: ["BenchPackage035"])
    ],
    targets: [
        .target(name: "BenchPackage035")
    ]
)
