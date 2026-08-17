// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage098",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage098", targets: ["BenchPackage098"])
    ],
    targets: [
        .target(name: "BenchPackage098")
    ]
)
