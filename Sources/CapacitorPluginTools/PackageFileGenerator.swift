import Foundation

public class PackageFileGenerator {
    let packageName: String
    let libName: String
    let capRepoName = "capacitor-swift-pm"
    let capLocation = "https://github.com/ionic-team/capacitor-swift-pm.git"
    let capVersion = "7.0.0"

    var packageText: String {
        return """
            // swift-tools-version: 5.9
            import PackageDescription

            let package = Package(
                name: "\(packageName)",
                platforms: [.iOS(.v14)],
                products: [
                    .library(
                        name: "\(libName)",
                        targets: ["\(libName)"])
                ],
                dependencies: [
                    .package(url: "\(capLocation)", from: "\(capVersion)")
                ],
                targets: [
                    .target(
                        name: "\(libName)",
                        dependencies: [
                            .product(name: "Capacitor", package: "\(capRepoName)"),
                            .product(name: "Cordova", package: "\(capRepoName)")
                        ],
                        path: "ios/Sources/\(libName)"),
                    .testTarget(
                        name: "\(libName)Tests",
                        dependencies: ["\(libName)"],
                        path: "ios/Tests/\(libName)Tests")
                ]
            )
            """
    }

    public init(packageName: String, libName: String) {
        self.packageName = packageName
        self.libName = libName
    }
    
    public func generateFile(at fileURL: URL) throws {
        let packageFileURL = URL(filePath: "Package.swift", directoryHint: .notDirectory, relativeTo: fileURL.baseURL)
        let packageFileString = packageText

        try packageFileString.write(to: packageFileURL, atomically: true, encoding: .utf8)
    }
}
