import Foundation

enum PersistenceCoder {
    static func encode(_ value: (some Codable)?) throws -> Data {
        try JSONEncoder().encode(value)
    }

    static func decode<T: Codable>(_ type: T.Type, from data: Data) throws -> T {
        try JSONDecoder().decode(T.self, from: data)
    }
}
