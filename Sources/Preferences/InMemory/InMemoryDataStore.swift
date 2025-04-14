import Foundation

public final class InMemoryDataStore {
    private var storage = [AnyKeyPath: Data]()
    private let queue = DispatchQueue(label: "com.leezy.persistence.inmemory.\(UUID())", attributes: .concurrent)

    public init() {}

    public subscript(key: AnyKeyPath) -> Data? {
        get {
            queue.sync {
                storage[key]
            }
        }
        set {
            queue.async(flags: .barrier) {
                self.storage[key] = newValue
            }
        }
    }

    public func removeValue(forKey key: AnyKeyPath) {
        queue.async(flags: .barrier) {
            self.storage.removeValue(forKey: key)
        }
    }

    public func removeAll() {
        queue.async(flags: .barrier) {
            self.storage.removeAll()
        }
    }

    public func contains(_ key: AnyKeyPath) -> Bool {
        queue.sync {
            storage.keys.contains(key)
        }
    }
}
