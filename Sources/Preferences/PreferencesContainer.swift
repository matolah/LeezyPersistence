import Foundation

final class PreferencesContainer {
    static let shared = PreferencesContainer()

    private var services = [String: BasePreferences]()

    private init() {}

    func register(service: BasePreferences, forIdentifier identifier: String) {
        services[identifier] = service
    }

    func resolve(forIdentifier identifier: String) -> BasePreferences? {
        return services[identifier]
    }
}
