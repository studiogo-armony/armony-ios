// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage008",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage008", targets: ["BenchPackage008"])
    ],
    targets: [
        .target(name: "BenchPackage008")
    ]
)
