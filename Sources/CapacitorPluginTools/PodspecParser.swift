import Foundation
import RegexBuilder

public struct PodspecParser {
    public let podName: String

    public init(at fileURL: URL) throws {
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

    public func modifyPodspecFile(at fileURL: URL) throws {
        var podspecText = try String(contentsOf: fileURL, encoding: .utf8)
        podspecText = podspecText.replacingOccurrences(of: "/Plugin/", with: "/Sources/")
        try podspecText.write(to: fileURL, atomically: true, encoding: .utf8)
    }
}
