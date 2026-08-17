// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage076",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage076", targets: ["BenchPackage076"])
    ],
    targets: [
        .target(name: "BenchPackage076")
    ]
)
