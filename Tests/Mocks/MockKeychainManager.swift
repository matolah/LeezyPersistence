import Foundation

@testable import LeezyPersistence

class MockKeychainManager: KeychainManagerProtocol {
    var values = [String: Data]()
    var error: Error?

    private(set) var promptMessagePassed: String?

    func load(_ key: String, withPromptMessage promptMessage: String?) throws -> Data? {
        if let error {
            throw error
        }
        promptMessagePassed = promptMessage
        return values[key]
    }

    func save(_ value: Data, forKey key: String) throws {
        if let error {
            throw error
        }
        values[key] = value
    }
}
