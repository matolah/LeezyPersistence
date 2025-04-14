import Foundation

actor PreferenceActor<Value: PersistenceValue, Preferences: PreferencesProtocol> {
    private let keyPath: ReferenceWritableKeyPath<Preferences, Value?>
    private let preferencesIdentifier: String

    private var preferences: Preferences {
        guard let preferences = PreferencesContainer.shared.resolve(forIdentifier: preferencesIdentifier) as? Preferences else {
            fatalError(PreferencesError.preferencesNotRegistered.localizedDescription)
        }
        return preferences
    }

    var value: Value? {
        preferences[keyPath: keyPath]
    }

    init(
        _ keyPath: ReferenceWritableKeyPath<Preferences, Value?>,
        preferences: String
    ) {
        self.keyPath = keyPath
        self.preferencesIdentifier = preferences
    }

    func update(to newValue: Value?) {
        preferences[keyPath: keyPath] = newValue
    }
}
