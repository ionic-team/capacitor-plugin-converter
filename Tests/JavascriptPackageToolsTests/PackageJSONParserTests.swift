import Testing
import Foundation
import JavascriptPackageTools

struct PackageJSONParserTests {
    var packageJSONParser: PackageJSONParser
    
    init() throws {
        let testJSON = try #require(Bundle.module.url(forResource: "package-test", withExtension: "json"))
        packageJSONParser = try PackageJSONParser(with: testJSON)
    }
    
    @Test("Correctly finds the podspec")
    func findsPodSpec() async throws {
        #expect(packageJSONParser.podspec == "Typical.podspec")
    }

}
