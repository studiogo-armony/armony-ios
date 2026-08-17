// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage087",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage087", targets: ["BenchPackage087"])
    ],
    targets: [
        .target(name: "BenchPackage087")
    ]
)
