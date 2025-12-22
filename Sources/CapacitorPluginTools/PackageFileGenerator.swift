import Foundation

public class PackageFileGenerator {
    let packageName: String
    let targetName: String
    let hasTests: Bool
    let capRepoName = "capacitor-swift-pm"
    let capLocation = "https://github.com/ionic-team/capacitor-swift-pm.git"
    let capVersion = "8.0.0"

    var packageText: String {
        var testTargetText = ""
        if hasTests {
            testTargetText = """
            ,
                    .testTarget(
                        name: "\(targetName)Tests",
                        dependencies: ["\(targetName)"],
                        path: "ios/Tests/\(targetName)Tests")
            """
        }
        return """
            // swift-tools-version: 5.9
            import PackageDescription

            let package = Package(
                name: "\(packageName)",
                platforms: [.iOS(.v15)],
                products: [
                    .library(
                        name: "\(packageName)",
                        targets: ["\(targetName)"])
                ],
                dependencies: [
                    .package(url: "\(capLocation)", from: "\(capVersion)")
                ],
                targets: [
                    .target(
                        name: "\(targetName)",
                        dependencies: [
                            .product(name: "Capacitor", package: "\(capRepoName)"),
                            .product(name: "Cordova", package: "\(capRepoName)")
                        ],
                        path: "ios/Sources/\(targetName)")\(testTargetText)
                ]
            )
            """
    }

    public init(packageName: String, targetName: String, hasTests: Bool) {
        self.packageName = packageName
        self.targetName = targetName
        self.hasTests = hasTests
    }
    
    public func generateFile(at fileURL: URL) throws {
        let packageFileURL = URL(filePath: "Package.swift", directoryHint: .notDirectory, relativeTo: fileURL.baseURL)
        let packageFileString = packageText

        try packageFileString.write(to: packageFileURL, atomically: true, encoding: .utf8)
    }
}
