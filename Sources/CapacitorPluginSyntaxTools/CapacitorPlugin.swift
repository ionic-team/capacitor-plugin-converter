import Foundation
import SwiftSyntax
import SwiftParser

public struct CapacitorPlugin {
    public let identifier: String
    public let jsName: String
    public var methods: [CapacitorPluginMethod] = []
    
    public init(identifier: String, jsName: String) {
        self.identifier = identifier
        self.jsName = jsName
    }
    
    public func modifySwiftFile(at fileURL: URL) throws {
        let source = try String(contentsOf: fileURL, encoding: .utf8)
        let sourceFile = Parser.parse(source: source)

        let capSyntax = CapacitorPluginSyntax(plugin: self)
        
        let incremented = AddPluginToClass(with: capSyntax).visit(sourceFile)

        var outputString: String = ""
        incremented.write(to: &outputString)
        try outputString.write(to: fileURL, atomically: true, encoding: .utf8)
    }
}

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
