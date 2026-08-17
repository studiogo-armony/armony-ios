// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage090",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage090", targets: ["BenchPackage090"])
    ],
    targets: [
        .target(name: "BenchPackage090")
    ]
)
