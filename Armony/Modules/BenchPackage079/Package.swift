// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage079",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage079", targets: ["BenchPackage079"])
    ],
    targets: [
        .target(name: "BenchPackage079")
    ]
)
