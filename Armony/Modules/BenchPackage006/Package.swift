// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage006",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage006", targets: ["BenchPackage006"])
    ],
    targets: [
        .target(name: "BenchPackage006")
    ]
)
