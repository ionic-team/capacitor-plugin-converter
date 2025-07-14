import Foundation
import Testing
@testable import CapacitorPluginTools

struct PackageFileGeneratorTests {
    let packageFileGenerator: PackageFileGenerator
    
    init() {
        packageFileGenerator = PackageFileGenerator(packageName: "CapacitorAppPlugin", targetName: "AppPlugin")
    }
    
    @Test("Generates expected Package.swift Text")
    func generatePackageSwiftContent() async throws {
        #expect(packageFileGenerator.packageText == expected)
    }
    
    let expected = """
        // swift-tools-version: 5.9
        import PackageDescription

        let package = Package(
            name: "CapacitorAppPlugin",
            platforms: [.iOS(.v14)],
            products: [
                .library(
                    name: "CapacitorAppPlugin",
                    targets: ["AppPlugin"])
            ],
            dependencies: [
                .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "7.0.0")
            ],
            targets: [
                .target(
                    name: "AppPlugin",
                    dependencies: [
                        .product(name: "Capacitor", package: "capacitor-swift-pm"),
                        .product(name: "Cordova", package: "capacitor-swift-pm")
                    ],
                    path: "ios/Sources/AppPlugin"),
                .testTarget(
                    name: "AppPluginTests",
                    dependencies: ["AppPlugin"],
                    path: "ios/Tests/AppPluginTests")
            ]
        )
        """
}
