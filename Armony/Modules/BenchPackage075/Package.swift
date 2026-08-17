// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage075",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage075", targets: ["BenchPackage075"])
    ],
    targets: [
        .target(name: "BenchPackage075")
    ]
)
