import Foundation
import CapacitorPluginSyntaxTools
import JavascriptPackageTools

public enum CapacitorPluginError: Error {
    case cantFindPluginSwift(String)

    public var message: String {
        switch self {
        case .cantFindPluginSwift(let name):
            return "Can't find \(name) or Plugin.swift in directory"
        }
    }
}

struct StandardError: TextOutputStream, Sendable {
    private static let handle = FileHandle.standardError

    public func write(_ string: String) {
        Self.handle.write(Data(string.utf8))
    }
}

public class CapacitorPluginPackage {
    public let pluginDirectoryName: String
    public let basePathURL: URL
    public let packageJSONURL: URL
    public let pluginSrcDirectoryURL: URL
    public let iosSrcDirectoryURL: URL
    public let files: [URL]

    private var oldPlugin: OldPlugin?
    private var packageJSONParser: PackageJSONParser
    
    public var identifier: String?
    public var plugin: CapacitorPlugin? {
        oldPlugin?.capacitorPlugin
    }

    public init(directoryName: String) throws {
        pluginDirectoryName = directoryName

        let fileManager = FileManager.default

        basePathURL = URL(filePath: directoryName, directoryHint: .isDirectory)
        packageJSONURL = URL(filePath: "package.json", directoryHint: .notDirectory, relativeTo: basePathURL)
        packageJSONParser = try PackageJSONParser(with: packageJSONURL)

        iosSrcDirectoryURL = URL(filePath: packageJSONParser.iosSrcDirectory, directoryHint: .isDirectory, relativeTo: basePathURL)

        let firstPluginDirectory = packageJSONParser.pluginDirectories.first ?? ""

        pluginSrcDirectoryURL = URL(filePath: firstPluginDirectory, directoryHint: .isDirectory, relativeTo: basePathURL)

        files = try fileManager.contentsOfDirectory(at: pluginSrcDirectoryURL, includingPropertiesForKeys: nil)
    }

    public func findObjCPluginFile() -> URL? {
        let mfiles = files.filter { $0.absoluteString.hasSuffix(".m") }

        if mfiles.count == 1, let url = mfiles.first {
            return url
        }
        return nil
    }

    public func parseObjCPluginFile(at url: URL) throws {
        oldPlugin = try OldPlugin(at: url)
        identifier = oldPlugin?.capacitorPlugin.identifier
    }

    public func findObjCHeaderFile() -> URL? {
        let headerFiles = files.filter { $0.absoluteString.hasSuffix(".h") }
        if headerFiles.count == 1, let url = headerFiles.first {
            return url
        }
        return nil
    }

    public func findSwiftPluginFile() throws(CapacitorPluginError) -> URL {
        var fileName = ""
        if let identifier {
            fileName = "\(identifier).swift"
            let fileURL = URL(filePath: fileName,
                              directoryHint: .notDirectory,
                              relativeTo: pluginSrcDirectoryURL)

            if (try? fileURL.checkResourceIsReachable()) == true {
                return fileURL
            } else {
                print("Warning: file \(fileURL.path()) not found, trying Plugin.swift")
            }

            let backupFileURL = URL(filePath: "Plugin.swift",
                                    directoryHint: .notDirectory,
                                    relativeTo: pluginSrcDirectoryURL)

            if (try? backupFileURL.checkResourceIsReachable()) == true {
                return backupFileURL
            }
        } else {
            let swiftFiles = files.filter { $0.absoluteString.hasSuffix("Plugin.swift") }
            if swiftFiles.count == 1, let url = swiftFiles.first {
                return url
            }
        }

        throw .cantFindPluginSwift(fileName)
    }

    public func findSwiftTestsPluginFile() -> URL? {
        if let identifier {
            let fileName = "\(identifier)Tests.swift"
            let fileURL = iosSrcDirectoryURL.appending(path: "PluginTests").appending(path: fileName)
            if (try? fileURL.checkResourceIsReachable()) == true {
                return fileURL
            } else {
                print("Warning: file \(fileURL.path()) not found, trying PluginTests.swift")
            }

            let backupFileURL = iosSrcDirectoryURL.appending(path: "PluginTests").appending(path: "PluginTests.swift")

            if (try? backupFileURL.checkResourceIsReachable()) == true {
                return backupFileURL
            }
        }
        return nil
    }

    public func findPodspecFile() throws -> URL {
        let fileName = packageJSONParser.podspec

        return URL(filePath: fileName, directoryHint: .notDirectory, relativeTo: basePathURL)
    }
    
    public func updatePackageJSON(for podName: String) throws {
        try? packageJSONParser.changeScript(named: "verify:ios",
                                           to: "xcodebuild -scheme \(podName) -destination generic/platform=iOS")
        
        var newFiles = packageJSONParser.files
        
        newFiles.removeAll(where: { $0 == "ios/Plugin" || $0 == "ios/Plugin/" })
        
        if !newFiles.contains(where: { $0 == "ios/"}) {
            newFiles.append("ios/Sources")
            newFiles.append("ios/Tests")
        }
        
        newFiles.append("Package.swift")
        
        packageJSONParser.files = newFiles
        
        try packageJSONParser.writePackageJSON()
    }

    public func setIdentifier(from fileURL: URL) throws {
        identifier = try IdentifierExtractor.getIdentifier(from: fileURL)
    }
}
