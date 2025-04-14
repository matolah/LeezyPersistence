import Foundation

@testable import LeezyPersistence

class MockKeychainManager: KeychainManagerProtocol {
    var values = [String: Data]()

    func load(_ key: String, ofKind kind: KeychainAccessKind) throws -> Data? {
        values[key]
    }

    func save(_ value: Data, forKey key: String, ofKind kind: KeychainAccessKind) throws {
        values[key] = value
    }
}
