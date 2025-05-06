import Foundation

public protocol UserDefaultPreferences: PreferencesProtocol {
    var userDefaults: UserDefaults { get }
}
