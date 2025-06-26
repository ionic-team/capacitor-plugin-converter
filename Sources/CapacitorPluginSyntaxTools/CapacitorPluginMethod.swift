import Foundation
import SwiftSyntax
import SwiftParser

public struct CapacitorPluginMethod {
    public let methodName: String
    public let returnType: CapacitorPluginReturnType
    
    var syntax: CapacitorPluginMethodSyntax {
        CapacitorPluginMethodSyntax(methodName: methodName, returnType: returnType)
    }
    
    public init(methodName: String, returnType: CapacitorPluginReturnType) {
        self.methodName = methodName
        self.returnType = returnType
    }
}
