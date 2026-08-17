// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage013",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage013", targets: ["BenchPackage013"])
    ],
    targets: [
        .target(name: "BenchPackage013")
    ]
)
