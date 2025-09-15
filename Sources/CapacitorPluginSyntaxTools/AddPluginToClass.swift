import Foundation
import SwiftSyntax
import SwiftParser

class AddPluginToClass: SyntaxRewriter {
    let capacitorPluginSyntax: CapacitorPluginSyntax

    init(with capacitorPluginSyntax: CapacitorPluginSyntax, viewMode: SyntaxTreeViewMode = .sourceAccurate) {
        self.capacitorPluginSyntax = capacitorPluginSyntax
        super.init(viewMode: viewMode)
    }

    override func visit(_ node: ClassDeclSyntax) -> DeclSyntax {
        guard let inheritedTypes = node.inheritanceClause?.inheritedTypes else {
            return DeclSyntax(node)
        }

        if let inheritedType = inheritedTypes.first(where: { $0.isNamed("CAPPlugin") }) {
            var newNode = capacitorPluginSyntax.addBridgedPluginConformance(node)
            newNode.memberBlock.members.insert(contentsOf: capacitorPluginSyntax.createMemberBlock(),
                                               at: node.memberBlock.members.startIndex)
            return DeclSyntax(newNode)
        } else {
            return DeclSyntax(node)
        }
    }

}

