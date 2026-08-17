// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage096",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage096", targets: ["BenchPackage096"])
    ],
    targets: [
        .target(name: "BenchPackage096")
    ]
)
