import Foundation

extension Cap2SPM {
    func deleteFiles(at fileList: [URL], shouldBackup: Bool) throws {
        if shouldBackup {
            try fileBackup(of: fileList)
        } else {
            try fileDelete(of: fileList)
        }
    }

    func moveItemCreatingIntermediaryDirectories(at: URL, to: URL) throws {
        print("Moving \(at.path()) to \(to.path())...")
        let parentPath = to.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: parentPath.path) {
            try FileManager.default.createDirectory(at: parentPath, withIntermediateDirectories: true, attributes: nil)
        }
        try FileManager.default.moveItem(at: at, to: to)
    }
        
    func fileBackup(of fileURLs: [URL]) throws {
        for fileURL in fileURLs {
            let fileBackupURL = fileURL.appendingPathExtension("old")
            print("Moving \(fileURL.path()) to \(fileBackupURL.path())...")
            try FileManager.default.moveItem(at: fileURL, to: fileBackupURL)
        }
    }

    func fileDelete(of fileURLs: [URL]) throws {
        for fileURL in fileURLs {
            print("Deleting \(fileURL.path())...")
            try FileManager.default.removeItem(at: fileURL)
        }
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
}
