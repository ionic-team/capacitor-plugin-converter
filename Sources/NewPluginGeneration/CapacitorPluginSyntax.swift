import Foundation
import SwiftSyntax
import SwiftParser

struct CapacitorPluginSyntax {
    let identifier: String
    let jsName: String
    var methods: [CapacitorPluginMethod] = []

    let defaultIndent = 4

    func createMemberBlock() -> MemberBlockItemListSyntax {
        let pluginIdentifier = addPublicStringConstantVariable(variableName: "identifier", stringValue: identifier)

        let jsName = addPublicStringConstantVariable(variableName: "jsName", stringValue: jsName)

        let pluginMethods = addPluginMethodDeclarations()

        let memberBlockItemList = MemberBlockItemListSyntax(arrayLiteral:
                                                            MemberBlockItemSyntax(leadingTrivia: .newline,
                                                                                  decl: pluginIdentifier),
                                                            MemberBlockItemSyntax(leadingTrivia: .newline,
                                                                                  decl: jsName), 
                                                            MemberBlockItemSyntax(leadingTrivia: .newline,
                                                                                  decl: pluginMethods)
        )

        return memberBlockItemList
    }

    func addBridgedPluginConformance(_ node: ClassDeclSyntax) -> ClassDeclSyntax {
        guard let inheritedTypes = node.inheritanceClause?.inheritedTypes else {
            return node
        }

        var newNode = node

        let currentLastElementIndex = inheritedTypes.index(before: inheritedTypes.endIndex)
        let capBridgePluginToken = TokenSyntax(.identifier("CAPBridgedPlugin"), presence: .present)
        let inheritedIdentifer = IdentifierTypeSyntax(name: capBridgePluginToken, trailingTrivia: .space)

        let inheritedType = InheritedTypeSyntax(type: inheritedIdentifer)

        newNode.inheritanceClause?.inheritedTypes[currentLastElementIndex].trailingTrivia = .spaces(0)
        newNode.inheritanceClause?.inheritedTypes[currentLastElementIndex].trailingComma = .commaToken(trailingTrivia: .space)
        newNode.inheritanceClause?.inheritedTypes.append(inheritedType)

        return newNode
    }

    private func addPublicStringConstantVariable(variableName: String, stringValue: String) -> VariableDeclSyntax {
        let declPublicModifier = DeclModifierSyntax(name: .keyword(.public),
                                                    trailingTrivia: .space)

        let identiferPattern = IdentifierPatternSyntax(leadingTrivia: .space,
                                                       identifier: .identifier(variableName))

        let stringSegmentList = StringLiteralSegmentListSyntax(arrayLiteral:
                .stringSegment(StringSegmentSyntax(content: .stringSegment(stringValue))))

        let stringLiteralExpr = StringLiteralExprSyntax(openingQuote: .stringQuoteToken(),
                                                        segments: stringSegmentList,
                                                        closingQuote: .stringQuoteToken())

        let initalizerClause = InitializerClauseSyntax(equal: .equalToken(leadingTrivia: .space, trailingTrivia: .space),
                                                       value: stringLiteralExpr)

        let patternBinding = PatternBindingSyntax(pattern: identiferPattern, initializer: initalizerClause)

        let indentifierDecl = VariableDeclSyntax(leadingTrivia: .spaces(defaultIndent),
                                                 modifiers: DeclModifierListSyntax(arrayLiteral: declPublicModifier),
                                                 bindingSpecifier: .keyword(.let),
                                                 bindings: PatternBindingListSyntax(arrayLiteral: patternBinding),
                                                 trailingTrivia: .space)

        return indentifierDecl
    }

    private func addPluginMethodDeclarations() -> VariableDeclSyntax {
        let declPublicModifier = DeclModifierSyntax(name: .keyword(.public),
                                                    trailingTrivia: .space)

        let identiferPattern = IdentifierPatternSyntax(leadingTrivia: .space,
                                                       identifier: .identifier("pluginMethods"))

        let typeAnnotation = TypeAnnotationSyntax(type: ArrayTypeSyntax(leadingTrivia: .space,
                                                                        element: IdentifierTypeSyntax(name: .identifier("CAPPluginMethod"))))

        var functionArray: [ArrayElementSyntax] = []

        for method in methods {
            let arrayElement = ArrayElementSyntax(leadingTrivia: .spaces(defaultIndent*2),
                                                  expression: method.functionCallExpr,
                                                  trailingComma: .commaToken(trailingTrivia: .newline))

            functionArray.append(arrayElement)
        }

        let arrayExpression = ArrayExprSyntax(leftSquare: .leftSquareToken(trailingTrivia: .newline),
                                              elements: ArrayElementListSyntax(functionArray),
                                              rightSquare: .rightSquareToken(leadingTrivia: .spaces(defaultIndent)))

        let initalizerClause = InitializerClauseSyntax(equal: .equalToken(leadingTrivia: .space, trailingTrivia: .space),
                                                       value: arrayExpression)

        let patternBinding = PatternBindingSyntax(pattern: identiferPattern, 
                                                  typeAnnotation: typeAnnotation,
                                                  initializer: initalizerClause)

        let indentifierDecl = VariableDeclSyntax(leadingTrivia: .spaces(defaultIndent),
                                                 modifiers: DeclModifierListSyntax(arrayLiteral: declPublicModifier),
                                                 bindingSpecifier: .keyword(.let),
                                                 bindings: PatternBindingListSyntax(arrayLiteral: patternBinding),
                                                 trailingTrivia: .space)

        return indentifierDecl
    }


    private func createCapacitorPluginFunction(functionName: String) -> FunctionCallExprSyntax {
        let declRef = DeclReferenceExprSyntax(baseName: .identifier("CAPPluginMethod"))

        let stringList = StringLiteralSegmentListSyntax(arrayLiteral:
                .stringSegment(StringSegmentSyntax(content: .stringSegment(functionName))))

        let nameValue = StringLiteralExprSyntax(openingQuote: .stringQuoteToken(),
                                                segments: stringList,
                                                closingQuote: .stringQuoteToken())

        let nameArgument = LabeledExprSyntax(leadingTrivia: nil,
                                             label: .identifier("name"),
                                             colon: .colonToken(trailingTrivia: .space),
                                             expression: nameValue,
                                             trailingComma: .commaToken(),
                                             trailingTrivia: .space)

        let returnArgument = LabeledExprSyntax(leadingTrivia: nil,
                                               label: .identifier("returnType"),
                                               colon: .colonToken(trailingTrivia: .space),
                                               expression: DeclReferenceExprSyntax(baseName: .identifier("CAPPluginReturnCallback")),
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
