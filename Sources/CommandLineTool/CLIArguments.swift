import Foundation
import CapacitorPluginTools

extension Cap2SPM {
    func getUrlsForArgs(package: CapacitorPluginPackage,
                        objcHeader: String?,
                        objcFile: String?,
                        swiftFile: String?,
                        swiftTestsFile: String?) throws -> (URL?, URL, URL?, URL?) {

        let mFileURL: URL?
        let swiftFileURL: URL
        let swiftTestsFileURL: URL?
        let hFileURL: URL?
        
        if let objcHeader {
            hFileURL = URL(filePath: objcHeader, directoryHint: .notDirectory)
        } else {
            hFileURL = package.findObjCHeaderFile()
        }

        if let objcFile {
            mFileURL = URL(filePath: objcFile, directoryHint: .notDirectory)
        } else {
            mFileURL = package.findObjCPluginFile()
        }

        if let mFileURL {
            try package.parseObjCPluginFile(at: mFileURL)
        }

        if let swiftFile {
            swiftFileURL = URL(filePath: swiftFile, directoryHint: .notDirectory)
        } else {
            swiftFileURL = try package.findSwiftPluginFile()
        }
        
        if mFileURL == nil && isSwiftFileUpdated(at: swiftFileURL) {
            try? package.setIdentifier(from: swiftFileURL)
        }

        if let swiftTestsFile {
            swiftTestsFileURL = URL(filePath: swiftTestsFile, directoryHint: .notDirectory)
        } else {
            swiftTestsFileURL = package.findSwiftTestsPluginFile()
        }

        return (mFileURL, swiftFileURL, hFileURL, swiftTestsFileURL)
    }
}
