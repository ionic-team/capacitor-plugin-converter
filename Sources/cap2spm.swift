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
    @Argument(help: "The swift file to parse")
    var filename: String

    mutating func run() throws {
        let oldPluginFileParser = OldPluginParser(fileName: "/Users/mark/Test.m")
        try oldPluginFileParser.parse()
        guard let capacitorPlugin = oldPluginFileParser.capacitorPlugin else { return }

        let url = URL(fileURLWithPath: filename)
        let source = try String(contentsOf: url, encoding: .utf8)
        let sourceFile = Parser.parse(source: source)
        let incremented = AddPluginToClass(with: capacitorPlugin).visit(sourceFile)
        print(incremented)
    }
}

