import Foundation

@propertyWrapper
public struct UserDefault<Value: PersistenceValue, Preferences: UserDefaultPreferences> {
    let defaultValue: Value?
    let key: String

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
        let container = instance.userDefaults
        let key = instance[keyPath: storageKeyPath].key
        let defaultValue = instance[keyPath: storageKeyPath].defaultValue

        guard let data = container.data(forKey: key) else {
            return defaultValue
        }

        return try? PersistenceCoder.decode(Value.self, from: data)
    }
}
