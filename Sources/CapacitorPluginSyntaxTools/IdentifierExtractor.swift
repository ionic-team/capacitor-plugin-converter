import Foundation
import SwiftSyntax
import SwiftParser

public class IdentifierExtractor: SyntaxVisitor {
    var value: String? = nil
    public override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        for binding in node.bindings {
            if let pattern = binding.pattern.as(IdentifierPatternSyntax.self), pattern.identifier.text == "identifier" {
                if let initValue = binding.initializer?.value, let stringLiteral = initValue.as(StringLiteralExprSyntax.self) {
                    let segments = stringLiteral.segments.compactMap {
                        segment -> String? in segment.as(StringSegmentSyntax.self)?.content.text
                    }
                    value = segments.joined()
                }
            }
        }
        return .skipChildren
    }

    public static func getIdentifier(from fileURL: URL) throws -> String? {
        let source = try String(contentsOf: fileURL, encoding: .utf8)
        let sourceFile = Parser.parse(source: source)
        let extractor = IdentifierExtractor(viewMode: SyntaxTreeViewMode.all)
        extractor.walk(sourceFile)
        return extractor.value
    }
}
