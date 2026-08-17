// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage083",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage083", targets: ["BenchPackage083"])
    ],
    targets: [
        .target(name: "BenchPackage083")
    ]
)
