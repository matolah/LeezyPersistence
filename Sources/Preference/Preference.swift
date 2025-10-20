import Combine
import SwiftUI

@propertyWrapper
public struct Preference<Value: PersistenceValue, Preferences: PreferencesProtocol>: DynamicProperty {
    let keyPath: ReferenceWritableKeyPath<Preferences, Value?>

    var preferences: Preferences {
        guard let preferences = PreferencesContainer.shared.resolve(type: Preferences.self) else {
            fatalError(PreferenceError.preferencesNotRegistered.localizedDescription)
        }
        return preferences
    }

    public var wrappedValue: Value? {
        get {
            preferences[keyPath: keyPath]
        }
        nonmutating set {
            preferences[keyPath: keyPath] = newValue
        }
    }

    public var projectedValue: Binding<Value?> {
        Binding(
            get: {
                wrappedValue
            },
            set: { value in
                wrappedValue = value
            }
        )
    }

    public init(_ keyPath: ReferenceWritableKeyPath<Preferences, Value?>) {
        self.keyPath = keyPath
    }

    /// Dynamic (scoped) access via an explicit provider key path (e.g. `\Prefs.$fileData`).
    public subscript(
        keyPrefix keyPrefix: String,
        provider providerKeyPath: KeyPath<Preferences, AnyDynamicPreferenceValueProvider>
    ) -> Value? {
        get {
            preferences[keyPath: providerKeyPath].value(withKeyPrefix: keyPrefix, using: preferences) as? Value
        }
        set {
            preferences[keyPath: providerKeyPath].setValue(
                newValue,
                withKeyPrefix: keyPrefix,
                using: preferences,
                wrappedKeyPath: keyPath
            )
        }
    }

    public func addSubscriber(onReceiveValue: @escaping (Value?) -> Void) -> AnyCancellable {
        publisher().sink { [onReceiveValue] _ in
            onReceiveValue(wrappedValue)
        }
    }

    public func publisher() -> AnyPublisher<Value?, Never> {
        preferences
            .preferencesChangedSubject
            .filter { changedKeyPath in
                changedKeyPath == keyPath
            }
            .map { _ in
                wrappedValue
            }
            .eraseToAnyPublisher()
    }

    public func subscribe(storingTo cancellables: inout Set<AnyCancellable>, onReceiveValue: @escaping (Value?) -> Void) {
        cancellables.insert(addSubscriber(onReceiveValue: onReceiveValue))
    }
}
