import Foundation

enum PackageJSONError: Error {
    case noPodspec
}

public struct PackageJSONParser: CustomDebugStringConvertible {
    private let package: PackageJSON

    public var npmName: String {
        package.name
    }

    public var version: String {
        package.version
    }

    public var podspec: String = ""

    public var iosSrcDirectory: String {
        package.capacitor.ios.src
    }

    public var pluginDirectories: [String] {
        var plugins: [String] = []

        for file in package.files {
            if file.hasPrefix(iosSrcDirectory) {
                plugins.append(file)
            }
        }

        return plugins
    }
    
    public var scripts: [String: String] {
        package.scripts
    }

    public init(with url: URL) throws {
        let data = try Data(contentsOf: url)
        package = try JSONDecoder().decode(PackageJSON.self, from: data)
        podspec = try findPodspec()
    }
    
    public var debugDescription: String {
        """
        NPM Name: \(npmName)
        Version: \(version)
        Podspec: \(podspec)
        iOS Sources: \(iosSrcDirectory)
        Plugin Directories: \(pluginDirectories)
        """
    }
    
    private func findPodspec() throws -> String {
        for file in package.files {
            if file.hasSuffix("podspec") {
                return file
            }
        }
        throw PackageJSONError.noPodspec
    }
}
