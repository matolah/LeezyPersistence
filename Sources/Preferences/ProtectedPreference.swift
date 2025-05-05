import Combine
import SwiftUI

@propertyWrapper
public struct ProtectedPreference<Value: PersistenceValue, Preferences: KeychainPreferences>: DynamicProperty {
    private var base: Preference<Value, Preferences>

    public var wrappedValue: Value? {
        get {
            base.wrappedValue
        }
        nonmutating set {
            base.wrappedValue = newValue
        }
    }

    public var projectedValue: Binding<Value?> {
        base.projectedValue
    }

    public init(_ keyPath: ReferenceWritableKeyPath<Preferences, Value?>) {
        base = Preference(keyPath)
    }

    /// Attempts to retrieve the value from a Keychain-backed `@Preference` using biometric or passcode authentication.
    ///
    /// > ⚠️ This should only be called on `Preference` properties that reference a `Keychain`-backed property in the `Preferences` type.
    /// Calling this method on a non-Keychain-backed preference will return `nil` and may trigger a debug assertion.
    ///
    /// - Parameter prompt: The prompt shown to the user during authentication.
    /// - Parameter keyPrefix: A runtime string that scopes the preference.
    /// - Returns: The securely retrieved value, or `nil` if authentication fails or the preference is not Keychain-backed.
    public subscript(prompt: String, keyPrefix: String? = nil) -> Value? {
        get {
            guard let keychainWrapper = base.resolvePropertyWrapper() as? Keychain<Value, Preferences> else {
                return nil
            }
            return keychainWrapper.value(withPrompt: prompt, preferences: base.preferences, keyPrefix: keyPrefix)
        }
        set {
            if let keyPrefix {
                base[keyPrefix] = newValue
            } else {
                base.wrappedValue = newValue
            }
        }
    }

    public func addSubscriber(onReceiveValue: @escaping (Value?) -> Void) -> AnyCancellable {
        base.addSubscriber(onReceiveValue: onReceiveValue)
    }

    public func publisher() -> AnyPublisher<Value?, Never> {
        base.publisher()
    }

    public func subscribe(storingTo cancellables: inout Set<AnyCancellable>, onReceiveValue: @escaping (Value?) -> Void) {
        base.subscribe(storingTo: &cancellables, onReceiveValue: onReceiveValue)
    }
}
