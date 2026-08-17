// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage069",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage069", targets: ["BenchPackage069"])
    ],
    targets: [
        .target(name: "BenchPackage069")
    ]
)
