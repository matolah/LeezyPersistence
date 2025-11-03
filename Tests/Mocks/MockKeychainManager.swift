import Foundation

@testable import LeezyPersistence

class MockKeychainManager: KeychainManagerProtocol {
    var values = [String: Data]()
    var error: Error?

    private(set) var promptMessagePassed: String?
    private(set) var shouldPromptPresencePassed: Bool?

    func load(_ key: String, withPromptMessage promptMessage: String?) throws -> Data? {
        if let error {
            throw error
        }
        promptMessagePassed = promptMessage
        return values[key]
    }
    
    func save(
        _ value: Data,
        forKey key: String,
        shouldPromptPresence: Bool
    ) throws {
        if let error {
            throw error
        }
        shouldPromptPresencePassed = shouldPromptPresence
        values[key] = value
    }
}
