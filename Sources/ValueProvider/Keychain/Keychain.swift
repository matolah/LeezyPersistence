import Foundation

@propertyWrapper
public struct Keychain<Value: PersistenceValue, Preferences: KeychainPreferences>: DynamicPreferenceValueProvider {
    let defaultValue: Value?
    let key: String

    public var projectedValue: any AnyDynamicPreferenceValueProvider {
        eraseToAnyDynamicPreferenceValueProvider()
    }

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
        defaultValue = wrappedValue
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
                try instance.keychainManager.save(encoded, forKey: value.key)
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
        let keychain = instance[keyPath: storageKeyPath]
        return keychain.value(withKey: keychain.key, using: instance)
    }

    private func value(withKey key: String, using preferences: Preferences, promptMessage: String? = nil) -> Value? {
        do {
            guard let data = try preferences.keychainManager.load(key, withPromptMessage: promptMessage) else {
                return defaultValue
            }
            return try? PersistenceCoder.decode(Value.self, from: data)
        } catch {
            preferences.handle(error: error)
            return defaultValue
        }
    }

    private func setValue<V>(
        _ newValue: Value?,
        withKey key: String,
        using preferences: Preferences,
        wrappedKeyPath: ReferenceWritableKeyPath<Preferences, V?>
    ) {
        guard value(withKey: key, using: preferences) != newValue else {
            return
        }

        do {
            let encoded = try PersistenceCoder.encode(newValue)
            try preferences.keychainManager.save(encoded, forKey: key)
            preferences.preferencesChangedSubject.send(wrappedKeyPath)
        } catch {
            preferences.handle(error: error)
        }
    }

    public func value(withKeyPrefix keyPrefix: String, using preferences: Preferences) -> Value? {
        return value(withKey: key.withPrefix(keyPrefix), using: preferences)
    }

    public func setValue<V>(
        _ newValue: Value?,
        withKeyPrefix keyPrefix: String,
        using preferences: Preferences,
        wrappedKeyPath: ReferenceWritableKeyPath<Preferences, V?>
    ) {
        setValue(newValue, withKey: key.withPrefix(keyPrefix), using: preferences, wrappedKeyPath: wrappedKeyPath)
    }

    func value(withPrompt prompt: String, preferences: Preferences, keyPrefix: String? = nil) -> Value? {
        let key = if let keyPrefix {
            key.withPrefix(keyPrefix)
        } else {
            key
        }
        return value(withKey: key, using: preferences, promptMessage: prompt)
    }
}
