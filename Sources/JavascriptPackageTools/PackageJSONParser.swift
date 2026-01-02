import Foundation
import SwiftyJSON

public enum PackageJSONError: Error {
    case noPodspec
    case scriptEntryNotFound
    case fileEntryNotFound
    case jsonStringGenerationFailed
}

public struct PackageJSONParser: CustomDebugStringConvertible {
    private let package: PackageJSON
    private let json: JSON
    private let jsonURL: URL
    public var jsonString: String
    
    public var npmName: String {
        package.name
    }

    public var version: String {
        package.version
    }
    
    public var files: [String] {
        package.files
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

    public init(with url: URL) throws {
        jsonURL = url
        
        let data = try Data(contentsOf: url)
        json = try JSON(data: data)
        jsonString = try String(contentsOf: url, encoding: .utf8)
        package = try JSONDecoder().decode(PackageJSON.self, from: data)
        podspec = try findPodspec()
    }
    
    public mutating func changeScript(named: String, to runString: String) throws(PackageJSONError) {
        if json["scripts"][named] != JSON.null {
            jsonString = jsonString.replacingOccurrences(of: json["scripts"][named].stringValue, with: runString)
        } else {
            throw .scriptEntryNotFound
        }
    }
    
    public mutating func setFiles() {
        var replacements: [String] = ["ios/Plugin", "ios/Plugin/"]

        var newFiles: String = """
            "Package.swift",
            """

        if !files.contains(where: { $0 == "ios/"}) {
            newFiles = """
        "ios/Sources",
            "ios/Tests",
            \(newFiles)
        """
        } else {
            replacements.append("ios/")
            newFiles = """
        "ios/",
            \(newFiles)
        """
        }

        replacements.forEach {replacement in
            jsonString = jsonString.replacingOccurrences(of: "\"\(replacement)\",", with: newFiles)
        }
    }

    public func writePackageJSON() throws {
        try jsonString.write(to: jsonURL, atomically: true, encoding: .utf8)
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
    
    private func findPodspec() throws(PackageJSONError) -> String {
        for file in package.files {
            if file.hasSuffix("podspec") {
                return file
            }
        }
        throw .noPodspec
    }
}
