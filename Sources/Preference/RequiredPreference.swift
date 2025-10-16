import Combine
import SwiftUI

@propertyWrapper
public struct RequiredPreference<Value: PersistenceValue, Preferences: PreferencesProtocol>: DynamicProperty {
    private var base: Preference<Value, Preferences>

    public var wrappedValue: Value {
        get {
            base.wrappedValue!
        }
        nonmutating set {
            base.wrappedValue = newValue
        }
    }

    public var projectedValue: Binding<Value> {
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
        base = Preference(keyPath)
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
    ) -> Value {
        get {
            return base[keyPrefix, provider: providerKeyPath]!
        }
        set {
            base[keyPrefix, provider: providerKeyPath] = newValue
        }
    }

    public func addSubscriber(onReceiveValue: @escaping (Value) -> Void) -> AnyCancellable {
        base.addSubscriber { [onReceiveValue] value in
            onReceiveValue(value!)
        }
    }

    public func publisher() -> AnyPublisher<Value, Never> {
        base.publisher()
            .map { value in
                value!
            }
            .eraseToAnyPublisher()
    }

    public func subscribe(storingTo cancellables: inout Set<AnyCancellable>, onReceiveValue: @escaping (Value) -> Void) {
        base.subscribe(storingTo: &cancellables) { [onReceiveValue] value in
            onReceiveValue(value!)
        }
    }
}
