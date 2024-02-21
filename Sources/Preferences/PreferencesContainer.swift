// Created by Mateus Lino

import Foundation

public final class PreferencesContainer {
    public static let shared = PreferencesContainer()

    private var services = [String: PreferencesProtocol]()

    private init() {}

    public func register(service: PreferencesProtocol, forIdentifier identifier: String) {
        services[identifier] = service
    }

    public func resolve(forIdentifier identifier: String) -> PreferencesProtocol? {
        return services[identifier]
    }
}
