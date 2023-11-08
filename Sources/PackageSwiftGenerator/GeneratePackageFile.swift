import Foundation
import SwiftSyntax


class GeneratePackageFile {
    let defaultIndent = 4

    func create() {
        let identiferPattern = IdentifierPatternSyntax(leadingTrivia: .space,
                                                       identifier: .identifier("package"))

        let packageExpression = DeclReferenceExprSyntax(baseName: .identifier("Package"))

        let stringSegmentList = StringLiteralSegmentListSyntax(arrayLiteral:
                .stringSegment(StringSegmentSyntax(content: .stringSegment("MyPluginName"))))

        let stringLiteralExpr = StringLiteralExprSyntax(openingQuote: .stringQuoteToken(),
                                                        segments: stringSegmentList,
                                                        closingQuote: .stringQuoteToken())


        let firstArg = LabeledExprSyntax(label: .identifier("name"), expression: stringLiteralExpr)
        let arguments = LabeledExprListSyntax(arrayLiteral: firstArg)

        let packageFunctionCall = FunctionCallExprSyntax(calledExpression: packageExpression, leftParen: .leftParenToken(), arguments: arguments, rightParen: .rightParenToken(), trailingTrivia: .space)

        let initalizerClause = InitializerClauseSyntax(equal: .equalToken(leadingTrivia: .space, trailingTrivia: .space),
                                                       value: packageFunctionCall)

        let patternBinding = PatternBindingSyntax(pattern: identiferPattern, initializer: initalizerClause)

        let indentifierDecl = VariableDeclSyntax(leadingTrivia: .spaces(defaultIndent),
                                                 bindingSpecifier: .keyword(.let),
                                                 bindings: PatternBindingListSyntax(arrayLiteral: patternBinding),
                                                 trailingTrivia: .space)

        let defDecl = DeclSyntax(fromProtocol: indentifierDecl)

        let codeBlock = CodeBlockItemSyntax(item: .decl(defDecl))

        let codeBlockList = CodeBlockItemListSyntax(arrayLiteral: codeBlock)

        let source = SourceFileSyntax(statements: codeBlockList)

        print(source.description)
    }
}
