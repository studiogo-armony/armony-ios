// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage097",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage097", targets: ["BenchPackage097"])
    ],
    targets: [
        .target(name: "BenchPackage097")
    ]
)
