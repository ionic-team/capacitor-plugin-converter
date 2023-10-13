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
        var newNode = capacitorPluginSyntax.addBridgedPluginConformance(node)
        newNode.memberBlock.members.insert(contentsOf: capacitorPluginSyntax.createMemberBlock(),
                                           at: node.memberBlock.members.startIndex)
        return DeclSyntax(newNode)
    }
}
