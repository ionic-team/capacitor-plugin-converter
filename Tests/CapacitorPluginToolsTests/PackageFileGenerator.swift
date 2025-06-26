import Foundation
import Testing
@testable import CapacitorPluginTools

struct PackageFileGeneratorTests {
    let packageFileGenerator: PackageFileGenerator
    
    init() {
        packageFileGenerator = PackageFileGenerator(packageName: "CapacitorAppPlugin", libName: "AppPlugin")
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
            platforms: [.iOS(.v13)],
            products: [
                .library(
                    name: "AppPlugin",
                    targets: ["AppPlugin"])
            ],
            dependencies: [
                .package(url: "https://github.com/ionic-team/capacitor6-spm-test.git", branch: "main")
            ],
            targets: [
                .target(
                    name: "AppPlugin",
                    dependencies: [
                        .product(name: "Capacitor", package: "capacitor6-spm-test"),
                        .product(name: "Cordova", package: "capacitor6-spm-test")
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

//@testable import cap2spm
//import XCTest
//
//class GeneratePackageFileTests: XCTestCase {
//    func testPackageGen() {
//        let packageFile = GeneratePackageFile(packageName: "CapacitorAppPlugin", libName: "AppPlugin")
//
//        XCTAssertEqual(packageFile.packageText, expected)
//    }
//}
