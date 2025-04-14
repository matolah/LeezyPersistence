import Foundation

@testable import LeezyPersistence

class MockPreferences: BasePreferences, FilePreferences, InMemoryPreferences, KeychainPreferences, UserDefaultPreferences {
    var fileDataStore = FileDataStore()
    var inMemoryDataStore = InMemoryDataStore()
    let keychainManager: KeychainManagerProtocol
    let userDefaults: UserDefaults

    init(
        identifier: String = "MockPreferences",
        keychainManager: KeychainManagerProtocol = MockKeychainManager(),
        userDefaults: UserDefaults = UserDefaults.standard
    ) {
        self.keychainManager = keychainManager
        self.userDefaults = userDefaults
        super.init(identifier: identifier)
    }
}
