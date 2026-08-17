// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage043",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage043", targets: ["BenchPackage043"])
    ],
    targets: [
        .target(name: "BenchPackage043")
    ]
)
