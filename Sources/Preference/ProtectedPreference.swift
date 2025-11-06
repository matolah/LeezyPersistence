import Combine
import SwiftUI

@propertyWrapper
public struct ProtectedPreference<Value: PersistenceValue, Preferences: KeychainPreferences>: DynamicProperty {
    private var base: Preference<Value, Preferences>
    private let providerKeyPath: KeyPath<Preferences, any AnyDynamicPreferenceValueProvider>

    public var wrappedValue: Value? {
        get {
            base.wrappedValue
        }
        nonmutating set {
            setValuePromptingPresence(newValue, keyPrefix: nil)
        }
    }

    public var projectedValue: Binding<Value?> {
        base.projectedValue
    }

    public init(
        _ keyPath: ReferenceWritableKeyPath<Preferences, Value?>,
        providerKeyPath: KeyPath<Preferences, any AnyDynamicPreferenceValueProvider>
    ) {
        base = Preference(keyPath)
        self.providerKeyPath = providerKeyPath
    }

    private func setValuePromptingPresence(_ value: Value?, keyPrefix: String?) {
        guard let keychainWrapper = base.preferences[keyPath: providerKeyPath] as? AnyPromptablePreferenceValueProvider else {
            return
        }
        keychainWrapper.setValuePromptingPresence(
            value,
            withKeyPrefix: keyPrefix,
            using: base.preferences,
            wrappedKeyPath: base.keyPath
        )
    }

    public subscript(
        prompt: String,
        keyPrefix: String? = nil
    ) -> Result<Value?, Error> {
        guard let keychainWrapper = base.preferences[keyPath: providerKeyPath] as? AnyPromptablePreferenceValueProvider else {
            return .success(nil)
        }
        do {
            return .success(
                try keychainWrapper.value(
                    withPrompt: prompt,
                    preferences: base.preferences,
                    keyPrefix: keyPrefix
                ) as? Value
            )
        } catch {
            return .failure(error)
        }
    }

    public func setValue(_ value: Value?, keyPrefix: String) {
        setValuePromptingPresence(value, keyPrefix: keyPrefix)
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
