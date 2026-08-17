// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage065",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage065", targets: ["BenchPackage065"])
    ],
    targets: [
        .target(name: "BenchPackage065")
    ]
)
