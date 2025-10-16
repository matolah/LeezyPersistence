import Foundation

@propertyWrapper
public struct File<Value: PersistenceValue, Preferences: FilePreferences>: DynamicPreferenceValueProvider {
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
            let file = instance[keyPath: storageKeyPath]
            file.setValue(newValue, withKey: file.key, using: instance, wrappedKeyPath: wrappedKeyPath)
        }
    }

    private static func value(
        _enclosingInstance instance: Preferences,
        storage storageKeyPath: ReferenceWritableKeyPath<Preferences, Self>
    ) -> Value? {
        let file = instance[keyPath: storageKeyPath]
        return file.value(withKey: file.key, using: instance)
    }

    private func value(withKey key: String, using preferences: Preferences) -> Value? {
        guard let data = preferences.fileDataStore[key] else {
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
            preferences.fileDataStore[key] = encoded
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
