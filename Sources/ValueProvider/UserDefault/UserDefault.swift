import Foundation

@propertyWrapper
public struct UserDefault<Value: PersistenceValue, Preferences: UserDefaultPreferences>: DynamicPreferenceValueProvider {
    let defaultValue: Value?
    let key: String

    public var projectedValue: AnyDynamicPreferenceValueProvider {
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
                let container = instance.userDefaults
                let key = instance[keyPath: storageKeyPath].key
                container.set(encoded, forKey: key)
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
        let userDefault = instance[keyPath: storageKeyPath]
        return userDefault.value(withKey: userDefault.key, using: instance)
    }

    private func value(withKey key: String, using preferences: Preferences) -> Value? {
        guard let data = preferences.userDefaults.data(forKey: key) else {
            return defaultValue
        }

        return try? PersistenceCoder.decode(Value.self, from: data)
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
            let container = preferences.userDefaults
            container.set(encoded, forKey: key)
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
}
