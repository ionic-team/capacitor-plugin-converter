//
//  File.swift
//  
//
//  Created by Mark Anderson on 10/16/23.
//

import Foundation

struct CapacitorPluginPackage {
    let pluginDirectoryName: String
    let basePathURL: URL
    let packageJSONURL: URL
    let pluginSrcDirectoryURL: URL
    let files: [URL]

    init(directoryName: String) throws {
        pluginDirectoryName = directoryName

        let fileManager = FileManager.default

        basePathURL = URL(filePath: directoryName, directoryHint: .isDirectory)
        packageJSONURL = URL(filePath: "package.json", directoryHint: .notDirectory, relativeTo: basePathURL)
        let package = try PackageJSONParser(with: packageJSONURL)

        let firstPluginDirectory = package.pluginDirectories.first ?? ""

        pluginSrcDirectoryURL = URL(filePath: firstPluginDirectory, directoryHint: .isDirectory, relativeTo: basePathURL)

        files = try fileManager.contentsOfDirectory(at: pluginSrcDirectoryURL, includingPropertiesForKeys: nil)
    }

}
