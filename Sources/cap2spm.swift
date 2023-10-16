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
//    @Option(help: "ObjectiveC Plugin File")
//    var objcFile: String
//
//    @Option(help: "The swift file to parse")
//    var swiftFile: String
//
//    @Option(name: .customLong("package-json"), help: "Package package.json")
//    var packageJSONFilename: String

    @Argument(help: "Plugin Directory")
    var pluginDirectory: String

    mutating func run() throws {
        let fileManager = FileManager.default

        let package = try PackageJSONParser(fileName: "\(pluginDirectory)/package.json")

        if let firstPluginDirectory = package.pluginDirectories.first {
            let fileNames = try fileManager.contentsOfDirectory(atPath: "\(pluginDirectory)/\(firstPluginDirectory)")
            for fileName in fileNames {
                if fileName.hasSuffix("Plugin.m") {
                    let oldPluginFileParser = OldPluginParser(fileName: "\(pluginDirectory)/\(firstPluginDirectory)/\(fileName)")
                    try oldPluginFileParser.parse()
                    guard let capacitorPlugin = oldPluginFileParser.capacitorPlugin else { return }

                    let url = URL(fileURLWithPath: "\(pluginDirectory)/\(firstPluginDirectory)/\(capacitorPlugin.identifier).swift")
                    let source = try String(contentsOf: url, encoding: .utf8)
                    let sourceFile = Parser.parse(source: source)
                    let incremented = AddPluginToClass(with: capacitorPlugin).visit(sourceFile)
                    print(incremented)
                }
            }
        }
    }
}

