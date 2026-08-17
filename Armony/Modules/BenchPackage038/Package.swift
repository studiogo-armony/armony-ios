// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage038",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage038", targets: ["BenchPackage038"])
    ],
    targets: [
        .target(name: "BenchPackage038")
    ]
)
