import Foundation
import SwiftSyntax
import SwiftParser

struct CapacitorPluginMethod {
    let methodName: String
    let returnType: CapacitorPluginReturnType

    private let nameIdent = TokenSyntax.identifier("name")
    private let returnTypeIdent = TokenSyntax.identifier("returnType")
    private let declRef = DeclReferenceExprSyntax(baseName: .identifier("CAPPluginMethod"))

    private var methodNameStringLiteral: StringLiteralSegmentListSyntax.Element {
        let token = TokenSyntax(.stringSegment(methodName), presence: .present)
        let stringSegmentElement = StringSegmentSyntax(content: token)
        return .stringSegment(stringSegmentElement)
    }

    var functionCallExpr: FunctionCallExprSyntax {
        let stringList = StringLiteralSegmentListSyntax(arrayLiteral: methodNameStringLiteral)

        let nameValue = StringLiteralExprSyntax(openingQuote: .stringQuoteToken(), segments: stringList, closingQuote: .stringQuoteToken())

        let nameArgument = LabeledExprSyntax(leadingTrivia: nil,
                                             label: nameIdent,
                                             colon: .colonToken(trailingTrivia: .space),
                                             expression: nameValue,
                                             trailingComma: .commaToken(),
                                             trailingTrivia: .space)

        let returnArgument = LabeledExprSyntax(leadingTrivia: nil,
                                               label: returnTypeIdent,
                                               colon: .colonToken(trailingTrivia: .space),
                                               expression: DeclReferenceExprSyntax(baseName: returnType.token),
                                               trailingTrivia: nil)

        let functionCallExpression = FunctionCallExprSyntax(leadingTrivia: nil,
                                                            calledExpression: declRef,
                                                            leftParen: .leftParenToken(),
                                                            arguments: LabeledExprListSyntax(arrayLiteral: nameArgument, returnArgument),
                                                            rightParen: .rightParenToken(),
                                                            trailingTrivia: nil)

        return functionCallExpression
    }
}
