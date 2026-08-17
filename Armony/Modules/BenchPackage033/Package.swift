// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage033",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage033", targets: ["BenchPackage033"])
    ],
    targets: [
        .target(name: "BenchPackage033")
    ]
)
