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

    var dynamicWrapper: (any AnyDynamicPreferenceValueProvider)? {
        guard let dynamicWrapper = resolvePropertyWrapper() as? (any DynamicPreferenceValueProvider) else {
            assertionFailure("The resolved wrapper does not conform to `DynamicPreferenceValueProvider`.")
            return nil
        }
        return dynamicWrapper.eraseToAnyDynamicPreferenceValueProvider()
    }
    
    public init(_ keyPath: ReferenceWritableKeyPath<Preferences, Value?>) {
        self.keyPath = keyPath
    }

    /// Accesses or modifies a dynamically-keyed preference value using a key prefix.
    ///
    /// This subscript is used when your preference key needs to vary based on runtime information
    /// — for example, when storing values per transaction ID, user ID, or other scoped keys.
    /// It allows you to provide a base key (e.g. `"test.key"`) and dynamically prepend a
    /// prefix to differentiate stored values (e.g. `"[1234] test.key"`).
    ///
    /// - Parameter keyPrefix: A runtime string that scopes the preference (e.g. a transaction ID).
    /// - Parameter provider: A key path to the projected value (e.g. `\Preferences.$fileData`) that resolves
    /// to the underlying storage provider conforming to `AnyDynamicPreferenceValueProvider`.
    /// This identifies the exact property wrapper responsible for dynamic value management.
    /// - Returns: The value stored under the dynamically-prefixed key, or `nil` if none exists.
    ///
    /// ### Usage Example:
    /// ```swift
    /// _preference["user_42"] = "ScopedValue"
    /// print(_preference["user_42"]) // => "ScopedValue"
    /// ```
    ///
    /// Note: The base preference value (accessed via `wrappedValue`) remains unaffected.
    public subscript(
        keyPrefix: String,
        provider providerKeyPath: KeyPath<Preferences, AnyDynamicPreferenceValueProvider>
    ) -> Value? {
        get {
            dynamicWrapper?.value(withKeyPrefix: keyPrefix, using: preferences) as? Value
        }
        set {
            dynamicWrapper?.setValue(newValue, withKeyPrefix: keyPrefix, using: preferences, wrappedKeyPath: keyPath)
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
