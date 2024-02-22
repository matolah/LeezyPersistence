// Created by Mateus Lino

import Combine
import XCTest

@testable import LeezyPersistence

class KeychainTests: XCTestCase {
    fileprivate class KeychainMockPreferences: MockPreferences {
        @Keychain<String, KeychainMockPreferences>("testKey") var testKey: String?

        required init(
            identifier: String = "MockPreferences",
            keychainManager: KeychainManagerProtocol,
            userDefaults: UserDefaults = UserDefaults.standard
        ) {
            super.init(identifier: identifier, keychainManager: keychainManager, userDefaults: userDefaults)
        }
    }

    fileprivate class Container {
        @Preference(\KeychainMockPreferences.testKey, preferences: "MockPreferences") var testKey
    }

    private var container: Container!
    private var mockPreferences: KeychainMockPreferences!
    private var keychainManager: MockKeychainManager!
    private var cancellable: AnyCancellable?

    override func setUp() {
        super.setUp()
        keychainManager = MockKeychainManager()
        mockPreferences = KeychainMockPreferences(keychainManager: keychainManager)
        container = Container()
    }

    override func tearDown() {
        keychainManager = nil
        cancellable = nil
        mockPreferences = nil
        container = nil
        super.tearDown()
    }

    func testKeychainSaveAndLoad() throws {
        let testValue = "TestValue"

        container.testKey = testValue
        XCTAssertEqual(testKeyKeychainValue(), testValue)
    }

    private func testKeyKeychainValue() -> String? {
        let data = try! keychainManager.load("testKey")!
        return try? JSONDecoder().decode(String.self, from: data)
    }

    func testUserDefaultValueChangedNotification() throws {
        let testValue = "TestValue"

        let keyPath: ReferenceWritableKeyPath<KeychainMockPreferences, String?> = \.testKey
        cancellable = mockPreferences.preferencesChangedSubject
            .sink { changedKeyPath in
                XCTAssertTrue(changedKeyPath == keyPath)
            }

        container.testKey = testValue
    }
}

