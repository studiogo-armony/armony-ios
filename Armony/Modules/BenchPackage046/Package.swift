// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage046",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage046", targets: ["BenchPackage046"])
    ],
    targets: [
        .target(name: "BenchPackage046")
    ]
)
