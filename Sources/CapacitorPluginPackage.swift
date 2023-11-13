//
//  File.swift
//  
//
//  Created by Mark Anderson on 10/16/23.
//

import Foundation

enum CapacitorPluginError: Error {
    case objcFileCount(Int)
    case objcHeaderCount(Int)
    case oldPluginMissing

    var message: String {
        switch self {
        case .objcFileCount(let numberOfFiles):
            return "Found \(numberOfFiles) Objective-C *.m files, expected \(numberOfFiles)"
        case .oldPluginMissing:
            return "Can't find OldPlugin"
        case .objcHeaderCount(let numberOfFiles):
            return "Found \(numberOfFiles) Objective-C Header files, expected \(numberOfFiles)"
        }
    }
}

class CapacitorPluginPackage {
    let pluginDirectoryName: String
    let basePathURL: URL
    let packageJSONURL: URL
    let pluginSrcDirectoryURL: URL
    let podspecURL: URL
    let files: [URL]

    var objcFilename: String?
    var objcHeaderFilename: String?
    var swiftFilename: String?
    var podspecFilename: String?

    var oldPlugin: OldPlugin?

    init(directoryName: String) throws {
        pluginDirectoryName = directoryName

        let fileManager = FileManager.default

        basePathURL = URL(filePath: directoryName, directoryHint: .isDirectory)
        packageJSONURL = URL(filePath: "package.json", directoryHint: .notDirectory, relativeTo: basePathURL)
        let package = try PackageJSONParser(with: packageJSONURL)

        let firstPluginDirectory = package.pluginDirectories.first ?? ""

        pluginSrcDirectoryURL = URL(filePath: firstPluginDirectory, directoryHint: .isDirectory, relativeTo: basePathURL)
        podspecURL = URL(filePath: package.podspec, directoryHint: .notDirectory, relativeTo: pluginSrcDirectoryURL)

        files = try fileManager.contentsOfDirectory(at: pluginSrcDirectoryURL, includingPropertiesForKeys: nil)
    }

    func findObjCPluginFile() throws -> URL {
        if let objcFilename {
            return URL(filePath: objcFilename, directoryHint: .notDirectory, relativeTo: basePathURL)
        }

        let mfiles = files.filter { $0.absoluteString.hasSuffix(".m") }

        guard mfiles.count == 1, let url = mfiles.first else { throw CapacitorPluginError.objcFileCount(mfiles.count) }
        
        oldPlugin = try OldPlugin(at: url)

        return url
    }

    func findObjCHeaderFile() throws -> URL {
        if let objcHeaderFilename {
            return URL(filePath: objcHeaderFilename, directoryHint: .notDirectory, relativeTo: basePathURL)
        }

        let headerFiles = files.filter { $0.absoluteString.hasSuffix(".h") }
        guard headerFiles.count == 1, let url = headerFiles.first else { throw CapacitorPluginError.objcFileCount(headerFiles.count) }

        return url
    }

    func findSwiftPluginFile(from url: URL) throws -> URL {
        if let swiftFilename = swiftFilename {
            return URL(filePath: swiftFilename, directoryHint: .notDirectory, relativeTo: basePathURL)
        }

        guard let oldPlugin else { throw CapacitorPluginError.oldPluginMissing }

        let fileName = "\(oldPlugin.capacitorPlugin.identifier).swift"

        return URL(filePath: fileName, directoryHint: .notDirectory, relativeTo: pluginSrcDirectoryURL)
    } 
}
