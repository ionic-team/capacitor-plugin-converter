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
}
