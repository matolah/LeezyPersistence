// Created by Mateus Lino

import Combine
import XCTest

@testable import LeezyPersistence

class UserDefaultTests: XCTestCase {
    fileprivate class UserDefaultsMockPreferences: MockPreferences {
        @UserDefault<String, UserDefaultsMockPreferences>("testKey") var testKey: String?

        required init(
            identifier: String = "MockPreferences",
            keychainManager: KeychainManagerProtocol = MockKeychainManager(),
            userDefaults: UserDefaults
        ) {
            super.init(identifier: identifier, keychainManager: keychainManager, userDefaults: userDefaults)
        }
    }

    @Preference(\UserDefaultsMockPreferences.testKey, preferences: "MockPreferences") var testKey

    private var mockPreferences: UserDefaultsMockPreferences!
    private var userDefaults: UserDefaults!
    private var cancellable: AnyCancellable?

    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults(suiteName: #file)!
        mockPreferences = UserDefaultsMockPreferences(userDefaults: userDefaults)
    }

    override func tearDown() {
        userDefaults.removePersistentDomain(forName: #file)
        userDefaults = nil
        cancellable = nil
        mockPreferences = nil
        super.tearDown()
    }

    func testUserDefaultSaveAndLoad() throws {
        let testValue = "TestValue"

        testKey = testValue
        XCTAssertEqual(testKeyUserDefaultsValue(), testValue)
    }

    private func testKeyUserDefaultsValue() -> String? {
        let data = userDefaults.data(forKey: "testKey")!
        return try? JSONDecoder().decode(String.self, from: data)
    }

    func testUserDefaultValueChangedNotification() throws {
        let testValue = "TestValue"

        let keyPath: ReferenceWritableKeyPath<UserDefaultsMockPreferences, String?> = \.testKey
        cancellable = mockPreferences.preferencesChangedSubject
            .sink { changedKeyPath in
                XCTAssertTrue(changedKeyPath == keyPath)
            }

        testKey = testValue
    }
}

