// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage052",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage052", targets: ["BenchPackage052"])
    ],
    targets: [
        .target(name: "BenchPackage052")
    ]
)
