import Foundation

@propertyWrapper
public struct Keychain<Value: PersistenceValue, Preferences: KeychainPreferences> {
    let kind: KeychainAccessKind
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

    public init(wrappedValue: Value? = nil, kind: KeychainAccessKind = .standard, _ key: String) {
        defaultValue = wrappedValue
        self.kind = kind
        self.key = key
    }

    public static subscript(
        _enclosingInstance instance: Preferences,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<Preferences, Value?>,
        storage storageKeyPath: ReferenceWritableKeyPath<Preferences, Self>
    ) -> Value? {
        get {
            value(_enclosingInstance: instance, storage: storageKeyPath)
        }
        set {
            guard value(_enclosingInstance: instance, storage: storageKeyPath) != newValue else {
                return
            }

            do {
                let encoded = try PersistenceCoder.encode(newValue)
                let value = instance[keyPath: storageKeyPath]
                try instance.keychainManager.save(encoded, forKey: value.key, ofKind: value.kind)
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
            let value = instance[keyPath: storageKeyPath]
            guard let data = try instance.keychainManager.load(value.key, ofKind: value.kind) else {
                return defaultValue
            }
            return try? PersistenceCoder.decode(Value.self, from: data)
        } catch {
            instance.handle(error: error)
            return defaultValue
        }
    }
}
