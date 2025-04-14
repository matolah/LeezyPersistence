import Combine
import SwiftUI

@propertyWrapper
public struct Preference<Value: PersistenceValue, Preferences: PreferencesProtocol>: DynamicProperty {
    private let actor: PreferenceActor<Value, Preferences>
    private let keyPath: ReferenceWritableKeyPath<Preferences, Value?>
    private let preferencesIdentifier: String
    private var cancellables = Set<AnyCancellable>()

    private var preferences: Preferences {
        guard let preferences = PreferencesContainer.shared.resolve(forIdentifier: preferencesIdentifier) as? Preferences else {
            fatalError(PreferencesError.preferencesNotRegistered.localizedDescription)
        }
        return preferences
    }

    public var atomicValue: Value? {
        get async {
            await actor.value
        }
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
            set: {
                wrappedValue = $0
            }
        )
    }

    public init(
        _ keyPath: ReferenceWritableKeyPath<Preferences, Value?>,
        preferences: String
    ) {
        self.actor = PreferenceActor(keyPath, preferences: preferences)
        self.keyPath = keyPath
        self.preferencesIdentifier = preferences
    }

    public func addSubscriber(onReceiveValue: @escaping (Value?) -> Void) -> AnyCancellable {
        return publisher().sink { [onReceiveValue] _ in
            onReceiveValue(self.wrappedValue)
        }
    }

    public func publisher() -> AnyPublisher<Value?, Never> {
        preferences
            .preferencesChangedSubject
            .filter { changedKeyPath in
                return changedKeyPath == keyPath
            }
            .map { _ in
                self.wrappedValue
            }
            .eraseToAnyPublisher()
    }

    public func subscribe(storingTo cancellables: inout Set<AnyCancellable>, onReceiveValue: @escaping (Value?) -> Void) {
        cancellables.insert(
            addSubscriber(onReceiveValue: onReceiveValue)
        )
    }

    public func atomicUpdate(to newValue: Value?) async {
        await actor.update(to: newValue)
    }
}

