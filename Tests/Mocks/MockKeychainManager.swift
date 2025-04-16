import Foundation

@testable import LeezyPersistence

class MockKeychainManager: KeychainManagerProtocol {
    var values = [String: Data]()
    private(set) var promptMessagePassed: String?

    func load(_ key: String, withPromptMessage promptMessage: String?) throws -> Data? {
        promptMessagePassed = promptMessage
        return values[key]
    }

    func save(_ value: Data, forKey key: String) throws {
        values[key] = value
    }
}
