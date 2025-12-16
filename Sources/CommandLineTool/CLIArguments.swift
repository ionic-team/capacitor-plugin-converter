import Foundation
import CapacitorPluginTools

extension Cap2SPM {
    func getUrlsForArgs(package: CapacitorPluginPackage,
                        objcHeader: String?,
                        objcFile: String?,
                        swiftFile: String?,
                        swiftTestsFile: String?) throws -> (URL, URL, URL, URL?) {

        let mFileURL: URL
        let swiftFileURL: URL
        let swiftTestsFileURL: URL?
        let hFileURL: URL
        
        if let objcHeader {
            hFileURL = URL(filePath: objcHeader, directoryHint: .notDirectory)
        } else {
            hFileURL = try package.findObjCHeaderFile()
        }

        if let objcFile {
            mFileURL = URL(filePath: objcFile, directoryHint: .notDirectory)
            try package.parseObjCPluginFile(at: mFileURL)
        } else {
            mFileURL = try package.findObjCPluginFile()
        }

        if let swiftFile {
            swiftFileURL = URL(filePath: swiftFile, directoryHint: .notDirectory)
        } else {
            swiftFileURL = try package.findSwiftPluginFile()
        }
        
        if let swiftTestsFile {
            swiftTestsFileURL = URL(filePath: swiftTestsFile, directoryHint: .notDirectory)
        } else {
            swiftTestsFileURL = package.findSwiftTestsPluginFile()
        }

        return (mFileURL, swiftFileURL, hFileURL, swiftTestsFileURL)
    }
}
