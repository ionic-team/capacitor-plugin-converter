import Foundation
import SwiftParser
import SwiftSyntax
import ArgumentParser

@main
struct Cap2SPM: ParsableCommand {
    @Flag(name: .customLong("backup"), inversion: .prefixedNo, help: "Should we make a backup?")
    var shouldBackup = false

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
            try capacitorPluginPackage.parseObjCPluginFile(at: mFileURL)
        } else {
            mFileURL = try capacitorPluginPackage.findObjCPluginFile()
        }

        if let swiftFile {
            swiftFileURL = URL(filePath: swiftFile, directoryHint: .notDirectory)
        } else {
            swiftFileURL = try capacitorPluginPackage.findSwiftPluginFile()
        }

        let podspecFileURL = try capacitorPluginPackage.findPodspecFile()

        guard let capPlugin = capacitorPluginPackage.oldPlugin?.capacitorPlugin else { return }

        try modifySwiftFile(at: swiftFileURL, plugin: capPlugin)
        try generatePackageSwiftFile(at: podspecFileURL, plugin: capPlugin)
        try modifyPodspec(at: podspecFileURL)
        try modifyGitignores(with: capacitorPluginPackage)

        var fileList = [mFileURL, hFileURL]
        if shouldBackup {
            try fileBackup(of: fileList)
        } else {
            let oldFiles = ["Plugin/Info.plist", "PluginTests/Info.plist", "Plugin.xcodeproj", "Plugin.xcworkspace", "Podfile"].compactMap {
                capacitorPluginPackage.iosSrcDirectoryURL.appending(path: $0)
            }
            fileList.append(contentsOf: oldFiles)
            try fileDelete(of: fileList)
        }
        try moveItemCreatingIntermediaryDirectories(at: capacitorPluginPackage.iosSrcDirectoryURL.appending(path: "Plugin"), to: capacitorPluginPackage.iosSrcDirectoryURL.appending(path: "Sources").appending(path: capPlugin.identifier))
        try moveItemCreatingIntermediaryDirectories(at: capacitorPluginPackage.iosSrcDirectoryURL.appending(path: "PluginTests"), to: capacitorPluginPackage.iosSrcDirectoryURL.appending(path: "Tests").appending(path: "\(capPlugin.identifier)Tests"))
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

    private func generatePackageSwiftFile(at fileURL: URL, plugin: CapacitorPluginSyntax) throws {
        let podspec = try PodspecParser(at: fileURL)
        
        let packageFileURL = URL(filePath: "Package.swift", directoryHint: .notDirectory, relativeTo: fileURL.baseURL)
        let packageFile = GeneratePackageFile(packageName: podspec.podName, libName: plugin.identifier)
        let packageFileString = packageFile.packageText

        try packageFileString.write(to: packageFileURL, atomically: true, encoding: .utf8)
    }

    private func modifyPodspec(at fileURL: URL) throws {
        var podspecText = try String(contentsOf: fileURL, encoding: .utf8)
        podspecText = podspecText.replacingOccurrences(of: "/Plugin/", with: "/Sources/")
        try podspecText.write(to: fileURL, atomically: true, encoding: .utf8)
    }

    private func modifyGitignores(with package: CapacitorPluginPackage) throws {
        let baseEntries = ["/Packages", "xcuserdata/" ,"DerivedData/", ".swiftpm/configuration/registries.json", ".swiftpm/xcode/package.xcworkspace/contents.xcworkspacedata", ".netrc"]
        var rootEntries = ["Pods", "Podfile.lock", "Package.resolved", "Build", "xcuserdata", "/.build"]
        rootEntries.append(contentsOf: baseEntries)
        var iosEntries = [".DS_Store", ".build"]
        iosEntries.append(contentsOf: baseEntries)
        let rootGitignore = package.basePathURL.appending(path: ".gitignore")
        let iOSGitignore = package.iosSrcDirectoryURL.appending(path: ".gitignore")
        try modifyGitignore(at: rootGitignore, with: rootEntries)
        try modifyGitignore(at: iOSGitignore, with: iosEntries)
    }

    private func modifyGitignore(at fileURL: URL, with content: [String]) throws {
        var gitignoreText = ""
        if FileManager.default.fileExists(atPath: fileURL.path()) {
            gitignoreText = try String(contentsOf: fileURL, encoding: .utf8)
        }
        content.forEach {
            if !gitignoreText.contains($0) {
                gitignoreText.append("\n\($0)")
            }
        }
        try gitignoreText.write(to: fileURL, atomically: true, encoding: .utf8)
    }

    private func moveItemCreatingIntermediaryDirectories(at: URL, to: URL) throws {
        print("Moving \(at.path()) to \(to.path())...")
        let parentPath = to.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: parentPath.path) {
            try FileManager.default.createDirectory(at: parentPath, withIntermediateDirectories: true, attributes: nil)
        }
        try FileManager.default.moveItem(at: at, to: to)
    }
}
