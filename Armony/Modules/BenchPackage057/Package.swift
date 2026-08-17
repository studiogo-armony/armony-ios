// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage057",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage057", targets: ["BenchPackage057"])
    ],
    targets: [
        .target(name: "BenchPackage057")
    ]
)
