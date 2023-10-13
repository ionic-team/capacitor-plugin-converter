import Foundation
import SwiftSyntax
import SwiftParser

enum CapacitorPluginReturnType: String {
    case none
    case promise
    case callback
    case watch
    case sync

    init?(with typeString: String) {
        switch typeString {
        case "CAPPluginReturnNone":
            self = .none
        case "CAPPluginReturnPromise":
            self = .promise
        case "CAPPluginReturnCallback":
            self = .callback
        case "CAPPluginReturnWatch":
            self = .watch
        case "CAPPluginReturnSync":
            self = .sync
        default:
            return nil
        }
    }

    var typeString: String {
        "CAPPluginReturn\(self.rawValue.capitalized)"
    }

    var token: TokenSyntax {
        .identifier(self.typeString)
    }
}
