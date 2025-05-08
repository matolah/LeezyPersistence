public protocol KeychainPreferences: PreferencesProtocol {
    var keychainManager: KeychainManagerProtocol { get }
}
