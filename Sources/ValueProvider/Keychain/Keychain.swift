import Foundation

@propertyWrapper
public struct Keychain<
    Value: PersistenceValue,
    Preferences: KeychainPreferences
>: DynamicPreferenceValueProvider {
    private struct Erased: AnyDynamicPreferenceValueProvider, AnyPromptablePreferenceValueProvider {
        private let base: Keychain

        init(_ base: Keychain) {
            self.base = base
        }

        func value(withKeyPrefix keyPrefix: String, using preferences: any PreferencesProtocol) -> Any? {
            base.value(withKeyPrefix: keyPrefix, using: preferences as! Preferences)
        }
        func setValue(
            _ newValue: Any?,
            withKeyPrefix keyPrefix: String,
            using preferences: any PreferencesProtocol,
            wrappedKeyPath: AnyKeyPath
        ) {
            base.setValue(
                newValue as? Value,
                withKeyPrefix: keyPrefix,
                using: preferences as! Preferences,
                wrappedKeyPath: wrappedKeyPath as! ReferenceWritableKeyPath<Preferences, Value?>
            )
        }

        func value(
            withPrompt prompt: String,
            preferences: any PreferencesProtocol,
            keyPrefix: String?
        ) throws -> Any? {
            guard let preferences = preferences as? Preferences else {
                assertionFailure("Preferences mismatch: expected \(Preferences.self), got \(type(of: preferences))")
                return nil
            }
            return try base.value(
                withPrompt: prompt,
                preferences: preferences,
                keyPrefix: keyPrefix
            )
        }
    }

    let shouldPromptPresence: Bool
    let defaultValue: Value?
    let key: String

    public var projectedValue: AnyDynamicPreferenceValueProvider {
        Erased(self)
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

    public init(
        wrappedValue: Value? = nil,
        _ key: String,
        shouldPromptPresence: Bool = false
    ) {
        defaultValue = wrappedValue
        self.key = key
        self.shouldPromptPresence = shouldPromptPresence
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
                try instance.keychainManager.save(
                    encoded,
                    forKey: value.key,
                    shouldPromptPresence: value.shouldPromptPresence
                )
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
        return try? keychain.value(withKey: keychain.key, using: instance)
    }

    private func value(
        withKey key: String,
        using preferences: Preferences,
        promptMessage: String? = nil,
        shouldThrowError: Bool = false
    ) throws -> Value? {
        do {
            guard let data = try preferences.keychainManager.load(key, withPromptMessage: promptMessage) else {
                return defaultValue
            }
            return try? PersistenceCoder.decode(Value.self, from: data)
        } catch {
            preferences.handle(error: error)
            if shouldThrowError {
                throw error
            } else {
                return defaultValue
            }
        }
    }

    private func setValue<V>(
        _ newValue: Value?,
        withKey key: String,
        using preferences: Preferences,
        wrappedKeyPath: ReferenceWritableKeyPath<Preferences, V?>
    ) {
        guard (try? value(withKey: key, using: preferences)) != newValue else {
            return
        }

        do {
            let encoded = try PersistenceCoder.encode(newValue)
            try preferences.keychainManager.save(
                encoded,
                forKey: key,
                shouldPromptPresence: shouldPromptPresence
            )
            preferences.preferencesChangedSubject.send(wrappedKeyPath)
        } catch {
            preferences.handle(error: error)
        }
    }

    public func value(withKeyPrefix keyPrefix: String, using preferences: Preferences) -> Value? {
        return try? value(withKey: key.withPrefix(keyPrefix), using: preferences)
    }

    public func setValue<V>(
        _ newValue: Value?,
        withKeyPrefix keyPrefix: String,
        using preferences: Preferences,
        wrappedKeyPath: ReferenceWritableKeyPath<Preferences, V?>
    ) {
        setValue(newValue, withKey: key.withPrefix(keyPrefix), using: preferences, wrappedKeyPath: wrappedKeyPath)
    }

    public func value(withPrompt prompt: String, preferences: Preferences, keyPrefix: String? = nil) throws -> Value? {
        let key = if let keyPrefix {
            key.withPrefix(keyPrefix)
        } else {
            key
        }
        return try value(withKey: key, using: preferences, promptMessage: prompt, shouldThrowError: true)
    }
}
