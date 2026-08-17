// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage036",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage036", targets: ["BenchPackage036"])
    ],
    targets: [
        .target(name: "BenchPackage036")
    ]
)
