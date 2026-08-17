// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage026",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage026", targets: ["BenchPackage026"])
    ],
    targets: [
        .target(name: "BenchPackage026")
    ]
)
