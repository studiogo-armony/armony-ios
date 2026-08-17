// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage044",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage044", targets: ["BenchPackage044"])
    ],
    targets: [
        .target(name: "BenchPackage044")
    ]
)
