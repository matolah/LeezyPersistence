import Combine
import SwiftUI

@propertyWrapper
public struct Preference<Value: PersistenceValue, Preferences: PreferencesProtocol>: DynamicProperty {
    private let keyPath: ReferenceWritableKeyPath<Preferences, Value?>
    private let preferencesIdentifier: String

    private var preferences: Preferences {
        guard let preferences = PreferencesContainer.shared.resolve(forIdentifier: preferencesIdentifier) as? Preferences else {
            fatalError(PreferencesError.preferencesNotRegistered.localizedDescription)
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

    public init(
        _ keyPath: ReferenceWritableKeyPath<Preferences, Value?>,
        preferences: String
    ) {
        self.keyPath = keyPath
        preferencesIdentifier = preferences
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

public extension Preference where Preferences: KeychainPreferences {
    /// Attempts to retrieve the value from a Keychain-backed `@Preference` using biometric or passcode authentication.
    ///
    /// > ⚠️ This should only be called on `Preference` properties that reference a `Keychain`-backed property in the `Preferences` type.
    /// Calling this method on a non-Keychain-backed preference will return `nil` and may trigger a debug assertion.
    ///
    /// - Parameter prompt: The prompt shown to the user during authentication.
    /// - Returns: The securely retrieved value, or `nil` if authentication fails or the preference is not Keychain-backed.
    func valueWithPrompt(_ prompt: String) -> Value? {
        let label = mirrorLabel(from: keyPath)
        let underscoredLabel = "_\(label)"

        let mirror = Mirror(reflecting: preferences)
        let keychainWrapper = mirror
            .children
            .first { child in
                child.label == underscoredLabel
            }?.value as? Keychain<Value, Preferences>
        guard let keychainWrapper else {
            // ⚠️ INTERNAL NOTE:
            // This relies on Swift's underscored property wrapper convention.
            // Ideally, we should migrate this to a macro-based or compiler-validated mechanism
            // once macros support type resolution of property wrappers behind key paths.
            assertionFailure("The preference property '\(label)' is not Keychain-backed")
            return nil
        }

        return keychainWrapper.value(withPrompt: prompt, preferences: preferences)
    }

    private func mirrorLabel(from keyPath: ReferenceWritableKeyPath<Preferences, Value?>) -> String {
        String(describing: keyPath)
            .components(separatedBy: ".")
            .last ?? "unknown"
    }
}
