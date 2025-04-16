import Foundation

public protocol KeychainManagerProtocol {
    func load(_ key: String, withPromptMessage promptMessage: String?) throws -> Data?
    func save(_ value: Data, forKey key: String) throws
}
