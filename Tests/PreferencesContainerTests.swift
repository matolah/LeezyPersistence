import Combine
import XCTest

@testable import LeezyPersistence

class PreferencesContainerTests: XCTestCase {
    func testRegisterAndResolvePreferences() {
        let preferences = BasePreferences(identifier: "BasePreferences")
        XCTAssertTrue(PreferencesContainer.shared.resolve(forIdentifier: "BasePreferences") === preferences)
        PreferencesContainer.shared.register(service: preferences, forIdentifier: "BasePreference")
        XCTAssertTrue(PreferencesContainer.shared.resolve(forIdentifier: "BasePreferences") === preferences)
    }

    func testRegisterAndResolveMultiplePreferencesOfSameInstance() {
        let preferences = BasePreferences(identifier: "BasePreferences")
        XCTAssertTrue(PreferencesContainer.shared.resolve(forIdentifier: "BasePreferences") === preferences)
        PreferencesContainer.shared.register(service: preferences, forIdentifier: "FakeBasePreferences")
        XCTAssertTrue(PreferencesContainer.shared.resolve(forIdentifier: "FakeBasePreferences") === preferences)
        XCTAssertTrue(PreferencesContainer.shared.resolve(forIdentifier: "BasePreferences") === preferences)
    }
}
