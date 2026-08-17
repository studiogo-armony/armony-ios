// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage041",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage041", targets: ["BenchPackage041"])
    ],
    targets: [
        .target(name: "BenchPackage041")
    ]
)
