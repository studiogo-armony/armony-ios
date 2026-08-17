// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage091",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage091", targets: ["BenchPackage091"])
    ],
    targets: [
        .target(name: "BenchPackage091")
    ]
)
