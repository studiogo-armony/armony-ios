// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage025",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage025", targets: ["BenchPackage025"])
    ],
    targets: [
        .target(name: "BenchPackage025")
    ]
)
