// Created by Mateus Lino

import Combine
import Foundation

// Based on https://www.avanderlee.com/swift/appstorage-explained/
public protocol PreferencesProtocol: AnyObject {
    var inMemoryDataStore: [AnyKeyPath: Data] { get set }
    var keychainManager: KeychainManagerProtocol { get }
    var userDefaults: UserDefaults { get }
    var preferencesChangedSubject: PassthroughSubject<AnyKeyPath, Never> { get }
}
