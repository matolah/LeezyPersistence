import Foundation

public protocol KeychainManagerProtocol {
    func load(_ key: String) throws -> Data?
    func save(_ value: Data, forKey key: String) throws
    func delete(_ key: String) throws
}
