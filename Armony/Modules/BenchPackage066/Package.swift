// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage066",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage066", targets: ["BenchPackage066"])
    ],
    targets: [
        .target(name: "BenchPackage066")
    ]
)
