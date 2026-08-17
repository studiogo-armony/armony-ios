// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage049",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage049", targets: ["BenchPackage049"])
    ],
    targets: [
        .target(name: "BenchPackage049")
    ]
)
