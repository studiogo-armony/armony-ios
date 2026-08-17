// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage018",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage018", targets: ["BenchPackage018"])
    ],
    targets: [
        .target(name: "BenchPackage018")
    ]
)
