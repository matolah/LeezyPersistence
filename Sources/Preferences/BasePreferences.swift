// Created by Mateus Lino

import Combine
import Foundation

// Based on https://www.avanderlee.com/swift/appstorage-explained/
open class BasePreferences {
    public internal(set) var inMemoryDataStore = [AnyKeyPath: Data]()
    public let keychainManager: KeychainManagerProtocol
    public let userDefaults: UserDefaults
    public private(set) var preferencesChangedSubject = PassthroughSubject<AnyKeyPath, Never>()

    public required init(
        identifier: String,
        keychainManager: KeychainManagerProtocol,
        userDefaults: UserDefaults
    ) {
        self.keychainManager = keychainManager
        self.userDefaults = userDefaults
        PreferencesContainer.shared.register(service: self, forIdentifier: identifier)
    }

    open func handle(error: Error) {}
}
