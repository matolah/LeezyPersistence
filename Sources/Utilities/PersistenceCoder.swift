import Foundation

enum PersistenceCoder {
    static func encode<T: Codable>(_ value: T?) throws -> Data {
        try JSONEncoder().encode(value)
    }

    static func decode<T: Codable>(_ type: T.Type, from data: Data) throws -> T {
        try JSONDecoder().decode(T.self, from: data)
    }
}
