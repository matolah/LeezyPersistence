import Foundation

public final class PreferencesContainer {
    public static let shared = PreferencesContainer()

    private var preferences: [String: any PreferencesProtocol] = [:]
    private let queue = DispatchQueue(label: "com.leezy.persistence.container.queue", attributes: .concurrent)

    private init() {}

    public func clear() {
        preferences = [:]
    }

    func register(preferences: some PreferencesProtocol) {
        queue.async(flags: .barrier) {
            self.preferences[String(reflecting: type(of: preferences))] = preferences
        }
    }

    func resolve<Preferences: PreferencesProtocol>(type: Preferences.Type = Preferences.self) -> Preferences? {
        queue.sync {
            preferences[String(reflecting: Preferences.self)] as? Preferences
        }
    }
}
