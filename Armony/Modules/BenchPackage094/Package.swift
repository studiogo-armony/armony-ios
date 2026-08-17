// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage094",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage094", targets: ["BenchPackage094"])
    ],
    targets: [
        .target(name: "BenchPackage094")
    ]
)
