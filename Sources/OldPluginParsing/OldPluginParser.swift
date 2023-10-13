import Foundation
import RegexBuilder

enum OldPluginParserError: Error {
    case pluginMissing
}

class OldPluginParser {
    let fileName: String
    var capacitorPlugin: CapacitorPluginSyntax?

    init(fileName: String) {
        self.fileName = fileName
    }

    func parse() throws {
        let url = URL(fileURLWithPath: fileName)
        let pluginSourceText = try String(contentsOf: url, encoding: .utf8)
        matchPlugin(text: pluginSourceText)
        try matchMethods(text: pluginSourceText)
    }

    private func matchPlugin(text: String) {
        let identiferRef = Reference(Substring.self)
        let jsNameRef = Reference(Substring.self)

        let pluginNameRegex = Regex {
            "CAP_PLUGIN("
            ZeroOrMore(.whitespace)
            Capture(as: identiferRef) {
                OneOrMore(.word)
            }
            ZeroOrMore(.whitespace)
            ","
            ZeroOrMore(.whitespace)
            "\""
            Capture(as: jsNameRef) {
                OneOrMore(.word)
            }
            "\""
            ZeroOrMore(.whitespace)
            ","
        }

        if let match = text.firstMatch(of: pluginNameRegex) {
            capacitorPlugin = CapacitorPluginSyntax(identifier: String(match[identiferRef]), jsName: String(match[jsNameRef]))
        }
    }

    private func matchMethods(text: String) throws {
        let methodNameRef = Reference(Substring.self)
        let returnTypeRef = Reference(Substring.self)
        let pluginMethodRegex = Regex {
          "CAP_PLUGIN_METHOD("
          ZeroOrMore(.whitespace)
          Capture(as: methodNameRef) {
            OneOrMore(.word)
          }
          ZeroOrMore(.whitespace)
          ","
          ZeroOrMore(.whitespace)
          Capture(as: returnTypeRef) {
            Regex {
              "CAPPluginReturn"
              ChoiceOf {
                "None"
                "Callback"
                "Promise"
                "Return"
                "Sync"
              }
            }
          }
          ")"
        }
        .anchorsMatchLineEndings()

        let matches = text.matches(of: pluginMethodRegex)

        guard capacitorPlugin != nil else { throw OldPluginParserError.pluginMissing }

        var pluginMethods: [CapacitorPluginMethod] = []

        for match in matches {
            let name = String(match[methodNameRef])
            if let returnTypeName = CapacitorPluginReturnType(with: String(match[returnTypeRef])) {
                pluginMethods.append(CapacitorPluginMethod(methodName: name, returnType: returnTypeName))
            }
        }

        self.capacitorPlugin?.methods = pluginMethods
    }
}
