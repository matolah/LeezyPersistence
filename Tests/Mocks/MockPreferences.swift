import Foundation

@testable import LeezyPersistence

class MockPreferences: BasePreferences, FilePreferences, InMemoryPreferences, KeychainPreferences, UserDefaultPreferences {
    var fileDataStore = FileDataStore()
    var inMemoryDataStore = InMemoryDataStore()
    let keychainManager: KeychainManagerProtocol
    let userDefaults: UserDefaults

    init(
        keychainManager: KeychainManagerProtocol = MockKeychainManager(),
        userDefaults: UserDefaults = UserDefaults.standard
    ) {
        self.keychainManager = keychainManager
        self.userDefaults = userDefaults
        super.init()
    }
}
