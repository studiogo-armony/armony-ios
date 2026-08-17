// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage050",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage050", targets: ["BenchPackage050"])
    ],
    targets: [
        .target(name: "BenchPackage050")
    ]
)
