// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage022",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage022", targets: ["BenchPackage022"])
    ],
    targets: [
        .target(name: "BenchPackage022")
    ]
)
