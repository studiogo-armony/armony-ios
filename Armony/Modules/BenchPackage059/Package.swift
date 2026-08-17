// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage059",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage059", targets: ["BenchPackage059"])
    ],
    targets: [
        .target(name: "BenchPackage059")
    ]
)
