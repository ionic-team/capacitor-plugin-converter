@testable import cap2spm
import XCTest

class CapacitorPluginMethodTests: XCTestCase {
    func testCapacitorPluginMethod() {
        let pluginMethod = CapacitorPluginMethod(methodName: "testMethod", returnType: .promise)
        var methodOutput = ""
        pluginMethod.functionCallExpr.write(to: &methodOutput)
        XCTAssertEqual(methodOutput, "CAPPluginMethod(name: \"testMethod\", returnType: CAPPluginReturnPromise)")
    }
}
