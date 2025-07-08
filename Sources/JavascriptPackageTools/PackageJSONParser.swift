import Foundation
import SwiftyJSON

public enum PackageJSONError: Error {
    case noPodspec
    case scriptEntryNotFound
    case fileEntryNotFound
}

public struct PackageJSONParser: CustomDebugStringConvertible {
    private let package: PackageJSON
    private var json: JSON
    private let jsonURL: URL
    
    public var npmName: String {
        package.name
    }

    public var version: String {
        package.version
    }
    
    public var files: [String] {
        get {
            package.files
        }
        set {
            json["files"] = JSON(newValue)
        }
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
    
    public var jsonString: String? {
        json.rawString(.utf8, options: [.withoutEscapingSlashes, .prettyPrinted])
    }

    public init(with url: URL) throws {
        jsonURL = url
        
        let data = try Data(contentsOf: url)
        json = try JSON(data: data)
        
        package = try JSONDecoder().decode(PackageJSON.self, from: data)
        podspec = try findPodspec()
    }
    
    public mutating func changeScript(named: String, to runString: String) throws(PackageJSONError) {
        if json["scripts"][named] != JSON.null {
            json["scripts"][named] = JSON(runString)
        } else {
            throw .scriptEntryNotFound
        }
    }
    
    public func writePackageJSON() throws {
        let data = try json.rawData()
        try data.write(to: jsonURL)
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
