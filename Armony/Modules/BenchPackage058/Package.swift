// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage058",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage058", targets: ["BenchPackage058"])
    ],
    targets: [
        .target(name: "BenchPackage058")
    ]
)
