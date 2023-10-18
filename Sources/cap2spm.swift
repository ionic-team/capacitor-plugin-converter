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
    @Option(help: "Objective-C header for file containing CAP_PLUGIN macro")
    var objcHeader: String?

    @Option(help: "Objective-C file containing CAP_PLUGIN macro")
    var objcFile: String?

    @Option(help: "Swift file containing class inheriting from CAPPlugin")
    var swiftFile: String?

    @Argument(help: "Plugin Directory")
    var pluginDirectory: String

    mutating func run() throws {
        let capacitorPluginPackage = try CapacitorPluginPackage(directoryName: pluginDirectory)

        let mFileURL = try capacitorPluginPackage.findObjCPluginFile()
        let swiftFileURL = try capacitorPluginPackage.findSwiftPluginFile(from: mFileURL)

        let source = try String(contentsOf: swiftFileURL, encoding: .utf8)
        let sourceFile = Parser.parse(source: source)

        guard let capPlugin = capacitorPluginPackage.oldPlugin?.capacitorPlugin else { return }

        let incremented = AddPluginToClass(with: capPlugin).visit(sourceFile)
        print(incremented)
    }
}


