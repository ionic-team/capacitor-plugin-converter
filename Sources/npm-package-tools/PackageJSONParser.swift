import Foundation

enum PackageJSONError: Error {
    case noPodspec
}

struct PackageJSONParser: CustomDebugStringConvertible {
    private let package: PackageJSON

    var npmName: String {
        package.name
    }

    var version: String {
        package.version
    }

    var podspec: String = ""

    var iosSrcDirectory: String {
        package.capacitor.ios.src
    }

    var pluginDirectories: [String] {
        var plugins: [String] = []

        for file in package.files {
            if file.hasPrefix(iosSrcDirectory) {
                plugins.append(file)
            }
        }

        return plugins
    }

    init(with url: URL) throws {
        let data = try Data(contentsOf: url)
        package = try JSONDecoder().decode(PackageJSON.self, from: data)
        podspec = try findPodspec()
    }

    private func findPodspec() throws -> String {
        for file in package.files {
            if file.hasSuffix("podspec") {
                return file
            }
        }
        throw PackageJSONError.noPodspec
    }

    var debugDescription: String {
        """
        NPM Name: \(npmName)
        Version: \(version)
        Podspec: \(podspec)
        iOS Sources: \(iosSrcDirectory)
        Plugin Directories: \(pluginDirectories)
        """
    }
}
