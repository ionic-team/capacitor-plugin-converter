import Foundation

struct PackageJSON: Codable {
    let name: String
    let version: String
    let files: [String]
    struct Capacitor: Codable {
        struct Ios {
            let src: String
        }
    }
}
