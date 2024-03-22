// Created by Mateus Lino

import Foundation

@testable import LeezyPersistence

class MockPreferences: MultiStoragePreferences {
    override init(
        identifier: String = "MockPreferences",
        keychainManager: KeychainManagerProtocol = MockKeychainManager(),
        userDefaults: UserDefaults = UserDefaults.standard
    ) {
        super.init(identifier: identifier, keychainManager: keychainManager, userDefaults: userDefaults)
    }
}
