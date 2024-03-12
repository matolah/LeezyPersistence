// Created by Mateus Lino

import Combine
import Foundation

public protocol PreferencesProtocol: AnyObject {
    var preferencesChangedSubject: PassthroughSubject<AnyKeyPath, Never> { get }
    func handle(error: Error)
}

// Based on https://www.avanderlee.com/swift/appstorage-explained/
open class BasePreferences: PreferencesProtocol {
    public private(set) var preferencesChangedSubject = PassthroughSubject<AnyKeyPath, Never>()

    public init(identifier: String) {
        PreferencesContainer.shared.register(service: self, forIdentifier: identifier)
    }

    open func handle(error: Error) {}
}

open class MultiStoragePreferences: BasePreferences, InMemoryPreferences, KeychainPreferences, UserDefaultPreferences {
    public var inMemoryDataStore = [AnyKeyPath: Data]()
    public let keychainManager: KeychainManagerProtocol
    public let userDefaults: UserDefaults

    public init(
        identifier: String,
        keychainManager: KeychainManagerProtocol,
        userDefaults: UserDefaults
    ) {
        self.keychainManager = keychainManager
        self.userDefaults = userDefaults
        super.init(identifier: identifier)
    }
}
