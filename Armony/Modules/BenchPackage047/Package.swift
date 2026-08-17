// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage047",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage047", targets: ["BenchPackage047"])
    ],
    targets: [
        .target(name: "BenchPackage047")
    ]
)
