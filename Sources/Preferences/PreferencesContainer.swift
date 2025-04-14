import Foundation

final class PreferencesContainer {
    static let shared = PreferencesContainer()

    private var services = [String: BasePreferences]()
    private let queue = DispatchQueue(label: "com.leezy.persistence.container.queue", attributes: .concurrent)

    private init() {}

    func register(service: BasePreferences, forIdentifier identifier: String) {
        queue.async(flags: .barrier) {
            self.services[identifier] = service
        }
    }

    func resolve(forIdentifier identifier: String) -> BasePreferences? {
        queue.sync {
            services[identifier]
        }
    }
}
