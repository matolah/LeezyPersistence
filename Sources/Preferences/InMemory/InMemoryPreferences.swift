import Foundation

public protocol InMemoryPreferences: PreferencesProtocol {
    var inMemoryDataStore: InMemoryDataStore { get }
}
