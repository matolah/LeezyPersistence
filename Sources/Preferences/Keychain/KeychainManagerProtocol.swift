import Foundation

public enum KeychainAccessKind {
    case standard
    case biometry(prompt: String)
    case biometryOrPasscode(prompt: String)
}

public protocol KeychainManagerProtocol {
    func load(_ key: String, ofKind kind: KeychainAccessKind) throws -> Data?
    func save(_ value: Data, forKey key: String, ofKind kind: KeychainAccessKind) throws
}
