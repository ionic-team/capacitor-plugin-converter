import Foundation
import SwiftSyntax
import SwiftParser

extension InheritedTypeSyntax {
    func isNamed(_ searchName: String) -> Bool {
        if let foundName = self.type.as(IdentifierTypeSyntax.self)?.name.text {
            return foundName == searchName
        } else {
            return false
        }
    }
}
