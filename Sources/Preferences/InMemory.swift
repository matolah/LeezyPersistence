// Created by Mateus Lino

import Foundation

@propertyWrapper
public struct InMemory<Value: PersistenceValue, Preferences: BasePreferences> {
    let defaultValue: Value?

    public var wrappedValue: Value? {
        get {
            fatalError("Wrapped value should not be used")
        }
        set {
            fatalError("Wrapped value should not be used")
        }
    }

    public init(wrappedValue: Value? = nil) {
        self.defaultValue = wrappedValue
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
                instance.inMemoryDataStore[storageKeyPath] = encoded
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

        guard let data = instance.inMemoryDataStore[storageKeyPath] else {
            return defaultValue
        }

        return try? JSONDecoder().decode(Value.self, from: data)
    }
}
