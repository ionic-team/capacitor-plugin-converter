// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import Foundation
import SwiftParser
import SwiftSyntax
import ArgumentParser

@main
struct Cap2SPM: ParsableCommand {
    @Argument(help: "Plugin Directory")
    var pluginDirectory: String

    mutating func run() throws {
        let capacitorPluginPackage = try CapacitorPluginPackage(directoryName: pluginDirectory)

        for file in capacitorPluginPackage.files {
            if file.absoluteString.hasSuffix("Plugin.m") {
                let oldPlugin = try OldPlugin(at: file)
                let url = URL(filePath: "\(oldPlugin.capacitorPlugin.identifier).swift",
                              directoryHint: .notDirectory,
                              relativeTo: capacitorPluginPackage.pluginSrcDirectoryURL)
                let source = try String(contentsOf: url, encoding: .utf8)
                let sourceFile = Parser.parse(source: source)
                let incremented = AddPluginToClass(with: oldPlugin.capacitorPlugin).visit(sourceFile)
                print(incremented)
            }
        }
    }
}

