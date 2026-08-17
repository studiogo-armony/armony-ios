// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage074",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage074", targets: ["BenchPackage074"])
    ],
    targets: [
        .target(name: "BenchPackage074")
    ]
)
