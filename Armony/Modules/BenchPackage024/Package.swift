// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage024",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage024", targets: ["BenchPackage024"])
    ],
    targets: [
        .target(name: "BenchPackage024")
    ]
)
