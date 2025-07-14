import Foundation
import ArgumentParser
import CapacitorPluginTools
import JavascriptPackageTools
import CapacitorPluginSyntaxTools

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
        
        (mFileURL, swiftFileURL, hFileURL) = try getUrlsForArgs(package: capacitorPluginPackage,
                                                                objcHeader: objcHeader,
                                                                objcFile: objcFile,
                                                                swiftFile: swiftFile)
        
        
        let podspecFileURL = try capacitorPluginPackage.findPodspecFile()
        let podspec = try PodspecParser(at: podspecFileURL)
        
        guard let capPlugin = capacitorPluginPackage.plugin else { return }
        
        try capPlugin.modifySwiftFile(at: swiftFileURL)
        
        let packageGenerator = PackageFileGenerator(packageName: podspec.podName, targetName: capPlugin.identifier)
        
        try packageGenerator.generateFile(at: podspecFileURL)
        
        var unneededFiles = [hFileURL, mFileURL]
        let oldFiles = ["Plugin/Info.plist",
                        "PluginTests/Info.plist",
                        "Plugin.xcodeproj",
                        "Plugin.xcworkspace",
                        "Podfile"].compactMap {
            capacitorPluginPackage.iosSrcDirectoryURL.appending(path: $0)
        }
        unneededFiles.append(contentsOf: oldFiles)
        
        try deleteFiles(at: unneededFiles, shouldBackup: shouldBackup)

        try modifyGitignores(for: capacitorPluginPackage)
    }
}
