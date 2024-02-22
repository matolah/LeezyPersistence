// Created by Mateus Lino

import Combine
import XCTest

@testable import LeezyPersistence

class BasePreferencesTests: XCTestCase {
    private var basePreferences: BasePreferences!

    override func setUp() {
        super.setUp()
        basePreferences = BasePreferences(
            identifier: "BasePreferences",
            keychainManager: MockKeychainManager(),
            userDefaults: UserDefaults.standard
        )
    }

    override func tearDown() {
        basePreferences = nil
        super.tearDown()
    }

    func testBasePreferencesAutoRegister() {
        XCTAssertTrue(PreferencesContainer.shared.resolve(forIdentifier: "BasePreferences") === basePreferences)
    }
}

