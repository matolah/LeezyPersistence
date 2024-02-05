// Created by Mateus Lino

import Combine
import SwiftUI

@propertyWrapper
public struct Preference<Value: PersistenceValue, Preferences: PreferencesProtocol>: DynamicProperty {
    private let keyPath: ReferenceWritableKeyPath<Preferences, Value?>
    private let preferences: Preferences
    private var cancellables = Set<AnyCancellable>()

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
        preferences: Preferences
    ) {
        self.keyPath = keyPath
        self.preferences = preferences
    }

    public func addSubscriber(onReceiveValue: @escaping (Value?) -> Void) -> AnyCancellable {
        return preferences
            .preferencesChangedSubject
            .filter { changedKeyPath in
                return changedKeyPath == keyPath
            }
            .sink { [onReceiveValue, wrappedValue] _ in
                onReceiveValue(wrappedValue)
            }
    }

    public func subscribe(storingTo cancellables: inout Set<AnyCancellable>, onReceiveValue: @escaping (Value?) -> Void) {
        cancellables.insert(
            addSubscriber(onReceiveValue: onReceiveValue)
        )
    }
}

