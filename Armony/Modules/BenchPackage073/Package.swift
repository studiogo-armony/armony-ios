// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BenchPackage073",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BenchPackage073", targets: ["BenchPackage073"])
    ],
    targets: [
        .target(name: "BenchPackage073")
    ]
)
