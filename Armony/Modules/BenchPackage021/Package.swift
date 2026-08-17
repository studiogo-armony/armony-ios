// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage021",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage021", targets: ["BenchPackage021"])
    ],
    targets: [
        .target(name: "BenchPackage021")
    ]
)
