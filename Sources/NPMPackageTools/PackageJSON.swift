import Foundation

struct PackageJSON: Codable {
    let name: String
    let version: String
    let files: [String]
    let capacitor: Capacitor
    let scripts: [String: String]
    
    struct Capacitor: Codable {
        let ios: Ios
        struct Ios: Codable {
            let src: String
        }
    }
}
