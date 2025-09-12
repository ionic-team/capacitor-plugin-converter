import Foundation
import CapacitorPluginSyntaxTools
import JavascriptPackageTools

public enum CapacitorPluginError: Error {
    case objcFileCount(Int)
    case objcHeaderCount(Int)
    case oldPluginMissing
    case cantFindPluginSwift(String)

    public var message: String {
        switch self {
        case .objcFileCount(let numberOfFiles):
            return "Found \(numberOfFiles) Objective-C *.m files, expected \(numberOfFiles)"
        case .oldPluginMissing:
            return "Can't find OldPlugin"
        case .objcHeaderCount(let numberOfFiles):
            return "Found \(numberOfFiles) Objective-C Header files, expected \(numberOfFiles)"
        case .cantFindPluginSwift(let name):
            return "Can't find \(name) or Plugin.swift in directory"
        }
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

    public func findObjCPluginFile() throws -> URL {
        let mfiles = files.filter { $0.absoluteString.hasSuffix(".m") }

        guard mfiles.count == 1, let url = mfiles.first else { throw CapacitorPluginError.objcFileCount(mfiles.count) }
        
        oldPlugin = try OldPlugin(at: url)

        return url
    }

    public func parseObjCPluginFile(at url: URL) throws {
        oldPlugin = try OldPlugin(at: url)
    }

    public func findObjCHeaderFile() throws -> URL {
        let headerFiles = files.filter { $0.absoluteString.hasSuffix(".h") }
        guard headerFiles.count == 1, let url = headerFiles.first else { throw CapacitorPluginError.objcFileCount(headerFiles.count) }

        return url
    }

    public func findSwiftPluginFile() throws(CapacitorPluginError) -> URL {
        guard let oldPlugin else { throw .oldPluginMissing }

        let fileName = "\(oldPlugin.capacitorPlugin.identifier).swift"

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

        throw .cantFindPluginSwift(fileName)
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
}
