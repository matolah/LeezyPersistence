import Foundation

/// Provides dynamic value access for preference property wrappers that support key prefixing.
/// This allows preferences to be stored and retrieved with dynamic keys at runtime.
public protocol DynamicPreferenceValueProvider {
    associatedtype Value
    associatedtype Preferences: PreferencesProtocol
    func value(withKeyPrefix keyPrefix: String, using preferences: Preferences) -> Value?
    func setValue(
        _ newValue: Value?,
        withKeyPrefix keyPrefix: String,
        using preferences: Preferences,
        wrappedKeyPath: ReferenceWritableKeyPath<Preferences, Value?>
    )
}

// Internal implementation detail for type erasure
public protocol AnyDynamicPreferenceValueProvider {
    func value<P: PreferencesProtocol>(withKeyPrefix keyPrefix: String, using preferences: P) -> Any?
    func setValue<P: PreferencesProtocol, V>(
        _ newValue: V?,
        withKeyPrefix keyPrefix: String,
        using preferences: P,
        wrappedKeyPath: ReferenceWritableKeyPath<P, V?>
    )
}

extension DynamicPreferenceValueProvider {
    func eraseToAnyDynamicPreferenceValueProvider() -> AnyDynamicPreferenceValueProvider {
        DynamicPreferenceValueProviderWrapper(self)
    }
}

private struct DynamicPreferenceValueProviderWrapper<Base: DynamicPreferenceValueProvider>: AnyDynamicPreferenceValueProvider {
    private let base: Base

    init(_ base: Base) {
        self.base = base
    }

    func value<P: PreferencesProtocol>(withKeyPrefix keyPrefix: String, using preferences: P) -> Any? {
        guard let preferences = preferences as? Base.Preferences else {
            return nil
        }
        return base.value(withKeyPrefix: keyPrefix, using: preferences)
    }

    func setValue<P: PreferencesProtocol, V>(
        _ newValue: V?,
        withKeyPrefix keyPrefix: String,
        using preferences: P,
        wrappedKeyPath: ReferenceWritableKeyPath<P, V?>
    ) {
        guard let preferences = preferences as? Base.Preferences else {
            return
        }

        let castedKeyPath = wrappedKeyPath as! ReferenceWritableKeyPath<Base.Preferences, Base.Value?>

        if let newValue = newValue as? Base.Value {
            base.setValue(newValue, withKeyPrefix: keyPrefix, using: preferences, wrappedKeyPath: castedKeyPath)
        } else if newValue == nil {
            base.setValue(nil, withKeyPrefix: keyPrefix, using: preferences, wrappedKeyPath: castedKeyPath)
        }
    }
}
