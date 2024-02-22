// Created by Mateus Lino

import Foundation

@testable import LeezyPersistence

class MockKeychainManager: KeychainManagerProtocol {
    var values = [String: Data]()

    func load(_ key: String) throws -> Data? {
        values[key]
    }
    
    func save(_ value: Data, forKey key: String) throws {
        values[key] = value
    }
    
    func delete(_ key: String) throws {
        values.removeValue(forKey: key)
    }
}
