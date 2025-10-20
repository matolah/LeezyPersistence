import Foundation

/// Concrete providers (e.g., File, UserDefault, Keychain) implement this.
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

/// Type-erased box used by callers via `\Preferences.$prop`.
public protocol AnyDynamicPreferenceValueProvider {
    func value(
        withKeyPrefix keyPrefix: String,
        using preferences: any PreferencesProtocol
    ) -> Any?

    func setValue(
        _ newValue: Any?,
        withKeyPrefix keyPrefix: String,
        using preferences: any PreferencesProtocol,
        wrappedKeyPath: AnyKeyPath
    )
}

public extension DynamicPreferenceValueProvider {
    @inlinable
    func eraseToAnyDynamicPreferenceValueProvider() -> AnyDynamicPreferenceValueProvider {
        _AnyDynamicPreferenceValueProviderBox(self)
    }
}

@usableFromInline
struct _AnyDynamicPreferenceValueProviderBox<Base: DynamicPreferenceValueProvider>: AnyDynamicPreferenceValueProvider {
    @usableFromInline let base: Base
    @inlinable init(_ base: Base) { self.base = base }

    @inlinable
    func value(
        withKeyPrefix keyPrefix: String,
        using preferences: any PreferencesProtocol
    ) -> Any? {
        guard let prefs = preferences as? Base.Preferences else {
            assertionFailure("Preferences mismatch: expected \(Base.Preferences.self), got \(type(of: preferences))")
            return nil
        }
        return base.value(withKeyPrefix: keyPrefix, using: prefs)
    }

    @inlinable
    func setValue(
        _ newValue: Any?,
        withKeyPrefix keyPrefix: String,
        using preferences: any PreferencesProtocol,
        wrappedKeyPath: AnyKeyPath
    ) {
        guard let prefs = preferences as? Base.Preferences else {
            assertionFailure("Preferences mismatch: expected \(Base.Preferences.self), got \(type(of: preferences))")
            return
        }
        guard let kp = wrappedKeyPath as? ReferenceWritableKeyPath<Base.Preferences, Base.Value?> else {
            assertionFailure("KeyPath mismatch. Expected ReferenceWritableKeyPath<\(Base.Preferences.self), \(Base.Value?.self)>")
            return
        }

        if let typed = newValue as? Base.Value {
            base.setValue(typed, withKeyPrefix: keyPrefix, using: prefs, wrappedKeyPath: kp)
        } else if newValue == nil {
            base.setValue(nil, withKeyPrefix: keyPrefix, using: prefs, wrappedKeyPath: kp)
        } else {
            assertionFailure("Value mismatch. Expected \(Base.Value.self), got \(type(of: newValue))")
        }
    }
}
