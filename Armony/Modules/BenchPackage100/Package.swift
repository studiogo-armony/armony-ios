// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage100",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage100", targets: ["BenchPackage100"])
    ],
    targets: [
        .target(name: "BenchPackage100")
    ]
)
