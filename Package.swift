// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "capacitor-plugin-converter",
    platforms: [.macOS(.v15)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "cap2spm",
            dependencies: [
                .target(name: "CapacitorPluginSyntaxTools"),
                .target(name: "JavascriptPackageTools"),
                .target(name: "CapacitorPluginTools"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax")
            ],
            path: "Sources/CommandLineTool"
        ),
        .target(name: "CapacitorPluginSyntaxTools"),
        .target(name: "CapacitorPluginTools",
                dependencies: [
                    .target(name: "JavascriptPackageTools")
                ]
        ),
        .target(name: "JavascriptPackageTools"),
        .testTarget(name: "CapacitorConverterTests",
                    dependencies: [
                        .target(name: "cap2spm"),
                        .product(name: "ArgumentParser", package: "swift-argument-parser"),
                        .product(name: "SwiftSyntax", package: "swift-syntax"),
                        .product(name: "SwiftParser", package: "swift-syntax")
                    ],
                    resources: [.copy("package-test.json")]
        )
    ]
)
