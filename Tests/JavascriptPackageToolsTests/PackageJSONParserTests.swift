import Testing
import Foundation
import JavascriptPackageTools

struct PackageJSONParserTests {
    let packageJSONParser: PackageJSONParser
    
    init() throws {
        let testJSON = try #require(Bundle.module.url(forResource: "package-new", withExtension: "json"))
        packageJSONParser = try PackageJSONParser(with: testJSON)
    }
    
    @Test("Correctly finds the podspec")
    func findsPodSpec() async throws {
        #expect(packageJSONParser.podspec == "Typical.podspec")
    }
    
    @Test("Can change scripts")
    func canChangeScript() async throws {
        var parser = packageJSONParser
        let oldString = try #require(parser.jsonString)
        try parser.changeScript(named: "verify:ios", to: "new-test")
        let calculatedSting = try #require(parser.jsonString)
        #expect(calculatedSting != oldString)
    }
    
    @Test("Can change files")
    func canSetFiles() async throws {
        var parser = packageJSONParser
        let oldString = try #require(parser.jsonString)
        parser.files = ["new", "list", "files"]
        let calculatedSting = try #require(parser.jsonString)
        #expect(calculatedSting != oldString)
    }
}
