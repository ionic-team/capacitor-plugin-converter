import Testing
import Foundation
import JavascriptPackageTools

struct PackageJSONParserTests {
    let newPackageJSONParser: PackageJSONParser
    let oldPackageJSONParser: PackageJSONParser
    
    init() throws {
        let newJSON = try #require(Bundle.module.url(forResource: "package-new", withExtension: "json"))
        let oldJSON = try #require(Bundle.module.url(forResource: "package-old", withExtension: "json"))
        newPackageJSONParser = try PackageJSONParser(with: newJSON)
        oldPackageJSONParser = try PackageJSONParser(with: oldJSON)
    }
    
    @Test("Correctly finds the podspec")
    func findsPodSpec() async throws {
        #expect(newPackageJSONParser.podspec == "Typical.podspec")
    }
    
    @Test("Can change scripts")
    func canChangeScript() async throws {
        var parser = oldPackageJSONParser
        let oldString = parser.jsonString
        try parser.changeScript(named: "verify:ios", to: "xcodebuild build -scheme TypicalPlugin -destination generic/platform=iOS")
        let calculatedSting = parser.jsonString
        #expect(calculatedSting != oldString)
    }
    
    @Test("Can change files")
    func canSetFiles() async throws {
        var parser = oldPackageJSONParser
        let oldString = parser.jsonString
        parser.setFiles()
        let calculatedSting = parser.jsonString
        #expect(calculatedSting != oldString)
    }

    @Test("Full package update")
    func replacedFilesAndScripts() async throws {
        var oldParser = oldPackageJSONParser
        try oldParser.changeScript(named: "verify:ios", to: "xcodebuild build -scheme TypicalPlugin -destination generic/platform=iOS")
        oldParser.setFiles()
        #expect(newPackageJSONParser.jsonString == oldParser.jsonString)
    }
}
