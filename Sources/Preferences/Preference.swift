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
        cancellables.insert(addSubscriber(onReceiveValue: onReceiveValue))
    }
}
