import Foundation

@propertyWrapper
public struct Keychain<Value: PersistenceValue, Preferences: KeychainPreferences> {
    let key: String
    let defaultValue: Value?

    public var wrappedValue: Value? {
        get {
            PropertyWrapperFailures.wrappedValueAssertionFailure()
            return nil
        }
        set {
            PropertyWrapperFailures.wrappedValueAssertionFailure()
        }
    }

    public init(wrappedValue: Value? = nil, _ key: String) {
        self.defaultValue = wrappedValue
        self.key = key
    }

    public static subscript(
        _enclosingInstance instance: Preferences,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<Preferences, Value?>,
        storage storageKeyPath: ReferenceWritableKeyPath<Preferences, Self>
    ) -> Value? {
        get {
            return value(_enclosingInstance: instance, storage: storageKeyPath)
        }
        set {
            guard value(_enclosingInstance: instance, storage: storageKeyPath) != newValue else {
                return
            }

            do {
                let encoded = try PersistenceCoder.encode(newValue)
                let key = instance[keyPath: storageKeyPath].key
                try instance.keychainManager.save(encoded, forKey: key)
                instance.preferencesChangedSubject.send(wrappedKeyPath)
            } catch {
                instance.handle(error: error)
            }
        }
    }

    private static func value(
        _enclosingInstance instance: Preferences,
        storage storageKeyPath: ReferenceWritableKeyPath<Preferences, Self>
    ) -> Value? {
        let defaultValue = instance[keyPath: storageKeyPath].defaultValue
        do {
            let key = instance[keyPath: storageKeyPath].key
            guard let data = try instance.keychainManager.load(key) else {
                return defaultValue
            }
            return try? PersistenceCoder.decode(Value.self, from: data)
        } catch {
            instance.handle(error: error)
            return defaultValue
        }
    }
}
