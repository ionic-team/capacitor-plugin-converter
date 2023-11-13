import Foundation
import RegexBuilder

struct PodspecParser {
    let podName: String

    init(at fileName: String) throws {
        let fileURL = URL(filePath: fileName, directoryHint: .notDirectory)
        let pluginSourceText = try String(contentsOf: fileURL, encoding: .utf8)
        podName = try PodspecParser.podnameMatcher(text: pluginSourceText)
    }

    private static func podnameMatcher(text: String) throws -> String {
        let podspecNameRef = Reference(Substring.self)

        let podNameRegex = Regex {
            "s.name"
            ZeroOrMore(.whitespace)
            "="
            ZeroOrMore(.whitespace)
            "'"
            Capture(as: podspecNameRef) {
              OneOrMore(.word)
            }
            "'"
          }

        if let match = text.firstMatch(of: podNameRegex) {
            return String(match[podspecNameRef])
        } else {
            throw OldPluginParserError.podspecNameMissing
        }
    }
}
