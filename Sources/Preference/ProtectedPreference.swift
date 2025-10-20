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
    /// - Returns: The securely retrieved value, or `nil` if authentication fails or the preference is not Keychain-backed.
    public subscript(prompt: String) -> Result<Value?, Error> {
        guard let keychainWrapper = base.resolvePropertyWrapper() as? Keychain<Value, Preferences> else {
            return .success(nil)
        }
        do {
            return .success(try keychainWrapper.value(withPrompt: prompt, preferences: base.preferences))
        } catch {
            return .failure(error)
        }
    }

    /// Attempts to retrieve the value from a Keychain-backed `@Preference` using biometric or passcode authentication.
    ///
    /// > ⚠️ This should only be called on `Preference` properties that reference a `Keychain`-backed property in the `Preferences` type.
    /// Calling this method on a non-Keychain-backed preference will return `nil` and may trigger a debug assertion.
    ///
    /// - Parameter prompt: The prompt shown to the user during authentication.
    /// - Parameter keyPrefix: A runtime string that scopes the preference.
    /// - Parameter provider: A key path to the projected value (e.g. `\Preferences.$fileData`) that resolves
    /// to the underlying storage provider conforming to `AnyDynamicPreferenceValueProvider`.
    /// This identifies the exact property wrapper responsible for dynamic value management.
    /// - Returns: The securely retrieved value, or `nil` if authentication fails or the preference is not Keychain-backed.
    public subscript(
        prompt: String,
        keyPrefix: String,
        provider providerKeyPath: KeyPath<Preferences, AnyDynamicPreferenceValueProvider>
    ) -> Result<Value?, Error> {
        guard let keychainWrapper = base.resolvePropertyWrapper() as? Keychain<Value, Preferences> else {
            return .success(nil)
        }
        do {
            return .success(try keychainWrapper.value(withPrompt: prompt, preferences: base.preferences, keyPrefix: keyPrefix))
        } catch {
            return .failure(error)
        }
    }

    public func setValue(_ value: Value?) {
        base.wrappedValue = value
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
