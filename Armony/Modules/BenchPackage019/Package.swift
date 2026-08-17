// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage019",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage019", targets: ["BenchPackage019"])
    ],
    targets: [
        .target(name: "BenchPackage019")
    ]
)
