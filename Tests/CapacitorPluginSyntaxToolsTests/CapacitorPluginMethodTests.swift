import Testing
import Foundation
@testable import CapacitorPluginSyntaxTools

struct CapacitorPluginMethodTests {
    let method: CapacitorPluginMethod
 
    init() {
        method = CapacitorPluginMethod(methodName: "testMethod", returnType: .promise)
    }
    
    @Test("Method is created correctly")
    func findsPodSpec() async throws {
        var methodOutput = ""
        method.syntax.functionCallExpr.write(to: &methodOutput)
        #expect(methodOutput == "CAPPluginMethod(name: \"testMethod\", returnType: CAPPluginReturnPromise)")
    }
}
