// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage020",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage020", targets: ["BenchPackage020"])
    ],
    targets: [
        .target(name: "BenchPackage020")
    ]
)
