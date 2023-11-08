import Foundation
import SwiftParser
import SwiftSyntax
import ArgumentParser

@main
struct Cap2SPM: ParsableCommand {
    @Flag(name: .customLong("backup"), inversion: .prefixedNo, help: "Should we make a backup? Defaults to true")
    var shouldBackup = true

    @Option(help: "Objective-C header for file containing CAP_PLUGIN macro")
    var objcHeader: String?

    @Option(help: "Objective-C file containing CAP_PLUGIN macro")
    var objcFile: String?

    @Option(help: "Swift file containing class inheriting from CAPPlugin")
    var swiftFile: String?

    @Argument(help: "Plugin Directory")
    var pluginDirectory: String

    mutating func run() throws {
        let mFileURL: URL
        let swiftFileURL: URL
        let hFileURL: URL

        let capacitorPluginPackage = try CapacitorPluginPackage(directoryName: pluginDirectory)

        if let objcHeader {
            hFileURL = URL(filePath: objcHeader, directoryHint: .notDirectory)
        } else {
            hFileURL = try capacitorPluginPackage.findObjCHeaderFile()
        }

        if let objcFile {
            mFileURL = URL(filePath: objcFile, directoryHint: .notDirectory)
        } else {
            mFileURL = try capacitorPluginPackage.findObjCPluginFile()
        }

        if let swiftFile {
            swiftFileURL = URL(filePath: swiftFile, directoryHint: .notDirectory)
        } else {
            swiftFileURL = try capacitorPluginPackage.findSwiftPluginFile(from: mFileURL)
        }

        guard let capPlugin = capacitorPluginPackage.oldPlugin?.capacitorPlugin else { return }

        try modifySwiftFile(at: swiftFileURL, plugin: capPlugin)

        let fileList = [mFileURL, hFileURL]
        if shouldBackup {
            try fileBackup(of: fileList)
        } else {
            try fileDelete(of: fileList)
        }
    }

    private func fileBackup(of fileURLs: [URL]) throws {
        for fileURL in fileURLs {
            let fileBackupURL = fileURL.appendingPathExtension("old")
            print("Moving \(fileURL.path()) to \(fileBackupURL.path())...")
            try FileManager.default.moveItem(at: fileURL, to: fileBackupURL)
        }
    }

    private func fileDelete(of fileURLs: [URL]) throws {
        for fileURL in fileURLs {
            print("Deleting \(fileURL.path())...")
            try FileManager.default.removeItem(at: fileURL)
        }
    }

    private func modifySwiftFile(at fileURL: URL, plugin: CapacitorPluginSyntax) throws {
        let source = try String(contentsOf: fileURL, encoding: .utf8)
        let sourceFile = Parser.parse(source: source)

        let incremented = AddPluginToClass(with: plugin).visit(sourceFile)

        if shouldBackup {
            try fileBackup(of: [fileURL])
        } else {
            try fileDelete(of: [fileURL])
        }

        var outputString: String = ""
        incremented.write(to: &outputString)
        try outputString.write(to: fileURL, atomically: true, encoding: .utf8)
    }
}
