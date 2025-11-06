import Foundation

public protocol KeychainManagerProtocol {
    func load(_ key: String, withPromptMessage promptMessage: String?) throws -> Data?
    func save(_ value: Data, forKey key: String, shouldPromptPresence: Bool) throws
 }

 public extension KeychainManagerProtocol {
     func save(_ value: Data, forKey key: String) throws {
         try save(value, forKey: key, shouldPromptPresence: false)
     }
 }
