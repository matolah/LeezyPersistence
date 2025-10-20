import Combine
import XCTest

@testable import LeezyPersistence

final class UserDefaultTests: XCTestCase {
    private class UserDefaultsMockPreferences: MockPreferences {
        @UserDefault<String, UserDefaultsMockPreferences>("testKey") var testKey: String?

        override init(
            keychainManager: KeychainManagerProtocol = MockKeychainManager(),
            userDefaults: UserDefaults
        ) {
            super.init(keychainManager: keychainManager, userDefaults: userDefaults)
        }
    }

    private class MockViewModel {
        @Preference(\UserDefaultsMockPreferences.testKey) var testKey
    }

    @Preference(\UserDefaultsMockPreferences.testKey) var testKey

    private var mockPreferences: UserDefaultsMockPreferences!
    private var userDefaults: UserDefaults!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults(suiteName: #file)!
        mockPreferences = UserDefaultsMockPreferences(userDefaults: userDefaults)
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        userDefaults.removePersistentDomain(forName: #file)
        userDefaults = nil
        cancellables = nil
        mockPreferences = nil
        super.tearDown()
    }

    func testUserDefaultSaveAndLoad() throws {
        let testValue = "TestValue"

        testKey = testValue
        XCTAssertEqual(testKeyUserDefaultsValue(), testValue)
    }

    private func testKeyUserDefaultsValue() -> String? {
        guard let data = userDefaults.data(forKey: "testKey") else {
            return nil
        }
        return try? JSONDecoder().decode(String.self, from: data)
    }
    
    func testDyamicKeyUserDefaultSaveAndLoad() throws {
        let testValue = "testValue"
        let testDynamicValue = "testDynamicValue"

        testKey = testValue
        _testKey[keyPrefix: "testDynamicKey", provider: \UserDefaultsMockPreferences.$testKey] = testDynamicValue
        let value = try? JSONDecoder().decode(String.self, from: userDefaults.data(forKey: "[testDynamicKey] testKey")!)
        XCTAssertEqual(value, testDynamicValue)
        XCTAssertEqual(testKeyUserDefaultsValue(), testValue)
    }

    func testUserDefaultValueChangedNotification() throws {
        let testValue = "TestValue"

        let keyPath: ReferenceWritableKeyPath<UserDefaultsMockPreferences, String?> = \.testKey
        mockPreferences.preferencesChangedSubject
            .sink { changedKeyPath in
                XCTAssertTrue(changedKeyPath == keyPath)
            }
            .store(in: &cancellables)

        testKey = testValue
    }

    func testPreferencesChangedSubjectValue() throws {
        let mockViewModel = MockViewModel()
        let expectation = XCTestExpectation(description: #function)
        _testKey.subscribe(storingTo: &cancellables) { value in
            XCTAssertEqual(value, "Mock123")
            expectation.fulfill()
        }
        testKey = "Mock123"
        XCTAssertEqual(mockViewModel.testKey, "Mock123")
        wait(for: [expectation])
    }
}
