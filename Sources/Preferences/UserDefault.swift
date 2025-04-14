import Foundation

public protocol UserDefaultPreferences: PreferencesProtocol {
    var userDefaults: UserDefaults { get }
}

@propertyWrapper
public struct UserDefault<Value: PersistenceValue, Preferences: UserDefaultPreferences> {
    let key: String
    let defaultValue: Value?

    public var wrappedValue: Value? {
        get {
            fatalError("Wrapped value should not be used")
        }
        set {
            fatalError("Wrapped value should not be used")
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
                let encoded = try JSONEncoder().encode(newValue)
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

        return try? JSONDecoder().decode(Value.self, from: data)
    }
}
