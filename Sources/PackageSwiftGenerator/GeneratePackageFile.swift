import Foundation

class GeneratePackageFile {
    let packageName: String
    let libName: String
    let capRepoName = "capacitor-swift-pm"
    let capLocation = "https://github.com/ionic-team/capacitor-swift-pm.git"
    let capVersion = "6.0.0"

    var packageText: String {
        return """
            // swift-tools-version: 5.9
            import PackageDescription

            let package = Package(
                name: "\(packageName)",
                platforms: [.iOS(.v13)],
                products: [
                    .library(
                        name: "\(libName)",
                        targets: ["\(libName)"])
                ],
                dependencies: [
                    .package(url: "\(capLocation)", branch: "\(capVersion)")
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

    init(packageName: String, libName: String) {
        self.packageName = packageName
        self.libName = libName
    }
}
