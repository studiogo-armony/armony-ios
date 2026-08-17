// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage023",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage023", targets: ["BenchPackage023"])
    ],
    targets: [
        .target(name: "BenchPackage023")
    ]
)
