// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage027",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage027", targets: ["BenchPackage027"])
    ],
    targets: [
        .target(name: "BenchPackage027")
    ]
)
