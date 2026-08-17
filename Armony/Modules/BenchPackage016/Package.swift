// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage016",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage016", targets: ["BenchPackage016"])
    ],
    targets: [
        .target(name: "BenchPackage016")
    ]
)
