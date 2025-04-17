import XCTest

@testable import LeezyPersistence

private class SimplePreferences: BasePreferences {}

final class PreferencesContainerTests: XCTestCase {
    private class NestedPreferences: BasePreferences {}

    override func setUp() {
        super.setUp()
        PreferencesContainer.shared.clear()
    }

    func testRegisterAndResolveSimplePreferences() {
        _ = SimplePreferences()

        let preferences2 = SimplePreferences()
        PreferencesContainer.shared.register(preferences: preferences2)

        guard let resolved = PreferencesContainer.shared.resolve(type: SimplePreferences.self) else {
            XCTFail("Failed to resolve SimplePreferences")
            return
        }

        XCTAssertTrue(resolved === preferences2)
    }

    func testRegisterAndResolveNestedPreferences() {
        _ = NestedPreferences()

        let preferences2 = NestedPreferences()
        PreferencesContainer.shared.register(preferences: preferences2)

        guard let resolved = PreferencesContainer.shared.resolve(type: NestedPreferences.self) else {
            XCTFail("Failed to resolve NestedPreferences")
            return
        }

        XCTAssertTrue(resolved === preferences2)
    }

    func testRegisterAndResolveDifferentPreferencesTypes() {
        let simplePrefs = SimplePreferences()
        PreferencesContainer.shared.register(preferences: simplePrefs)

        let nestedPrefs = NestedPreferences()
        PreferencesContainer.shared.register(preferences: nestedPrefs)

        guard let resolvedSimple = PreferencesContainer.shared.resolve(type: SimplePreferences.self),
              let resolvedNested = PreferencesContainer.shared.resolve(type: NestedPreferences.self)
        else {
            XCTFail("Failed to resolve preferences")
            return
        }

        XCTAssertTrue(resolvedSimple === simplePrefs)
        XCTAssertTrue(resolvedNested === nestedPrefs)
    }

    func testClear() {
        let preferences = BasePreferences()
        XCTAssertTrue(PreferencesContainer.shared.resolve(type: BasePreferences.self) === preferences)
        PreferencesContainer.shared.clear()
        XCTAssertNil(PreferencesContainer.shared.resolve(type: BasePreferences.self))
    }
}
