@testable import cap2spm
import XCTest

final class PackageJSONParserTests: XCTestCase {
    var packageJSONParser: PackageJSONParser?
    
    override func setUpWithError() throws {
        let jsonFileURL = try XCTUnwrap(Bundle.module.url(forResource: "package-test", withExtension: "json"))
        packageJSONParser = try XCTUnwrap(PackageJSONParser(with: jsonFileURL))
    }
    
    func testPodspecFinder() throws {
        XCTAssertEqual(packageJSONParser?.podspec, "Typical.podspec")
    }
}
