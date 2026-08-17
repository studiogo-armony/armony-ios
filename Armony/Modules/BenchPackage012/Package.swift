// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage012",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage012", targets: ["BenchPackage012"])
    ],
    targets: [
        .target(name: "BenchPackage012")
    ]
)
