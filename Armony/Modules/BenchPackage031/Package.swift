// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage031",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage031", targets: ["BenchPackage031"])
    ],
    targets: [
        .target(name: "BenchPackage031")
    ]
)
