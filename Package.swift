// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "capacitor-plugin-converter",
    platforms: [.macOS(.v15)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.6.2"),
        .package(url: "https://github.com/apple/swift-syntax.git", from: "601.0.1"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.2"),
    ],
    targets: [
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
        .target(name: "CapacitorPluginSyntaxTools",
                dependencies: [
                    .product(name: "ArgumentParser", package: "swift-argument-parser"),
                    .product(name: "SwiftSyntax", package: "swift-syntax"),
                    .product(name: "SwiftParser", package: "swift-syntax")
                ]
        ),
        .target(name: "CapacitorPluginTools",
                dependencies: [
                    .target(name: "CapacitorPluginSyntaxTools"),
                    .target(name: "JavascriptPackageTools")
                ]
        ),
        .target(name: "JavascriptPackageTools",
                dependencies: [
                    .product(name: "SwiftyJSON", package: "SwiftyJSON")
                ]
        ),
        
        // Test Targets
        .testTarget(name: "JavascriptPackageToolsTests",
                    dependencies: [
                        .target(name: "JavascriptPackageTools"),
                    ],
                    resources: [.copy("../Resources/package-new.json")]
        ),
        .testTarget(name: "CapacitorPluginSyntaxToolsTests",
                dependencies: [
                    .target(name: "CapacitorPluginSyntaxTools"),
                    .product(name: "SwiftSyntax", package: "swift-syntax"),
                    .product(name: "SwiftParser", package: "swift-syntax")
                ]
        ),
        .testTarget(name: "CapacitorPluginToolsTests",
                dependencies: [
                    .target(name: "CapacitorPluginTools")
                ]
        ),
    ]
)
