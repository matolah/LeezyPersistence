import Combine
import SwiftUI

@propertyWrapper
public struct RequiredPreference<Value: PersistenceValue, Preferences: PreferencesProtocol>: DynamicProperty {
    private var base: Preference<Value, Preferences>

    public var wrappedValue: Value {
        get {
            base.wrappedValue!
        }
        nonmutating set {
            base.wrappedValue = newValue
        }
    }

    public var projectedValue: Binding<Value> {
        Binding(
            get: {
                wrappedValue
            },
            set: { value in
                wrappedValue = value
            }
        )
    }

    public init(_ keyPath: ReferenceWritableKeyPath<Preferences, Value?>) {
        base = Preference(keyPath)
    }

    public subscript(keyPrefix: String) -> Value {
        get {
            return base[keyPrefix]!
        }
        set {
            base[keyPrefix] = newValue
        }
    }

    public func addSubscriber(onReceiveValue: @escaping (Value) -> Void) -> AnyCancellable {
        base.addSubscriber { [onReceiveValue] value in
            onReceiveValue(value!)
        }
    }

    public func publisher() -> AnyPublisher<Value, Never> {
        base.publisher()
            .map { value in
                value!
            }
            .eraseToAnyPublisher()
    }

    public func subscribe(storingTo cancellables: inout Set<AnyCancellable>, onReceiveValue: @escaping (Value) -> Void) {
        base.subscribe(storingTo: &cancellables) { [onReceiveValue] value in
            onReceiveValue(value!)
        }
    }
}
