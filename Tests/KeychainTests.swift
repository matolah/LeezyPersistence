import Combine
import XCTest

@testable import LeezyPersistence

class KeychainTests: XCTestCase {
    fileprivate class KeychainMockPreferences: MockPreferences {
        @Keychain<String, KeychainMockPreferences>("testKey") var testKey: String?

        override init(
            identifier: String = "MockPreferences",
            keychainManager: KeychainManagerProtocol,
            userDefaults: UserDefaults = UserDefaults.standard
        ) {
            super.init(identifier: identifier, keychainManager: keychainManager, userDefaults: userDefaults)
        }
    }

    fileprivate class MockViewModel {
        @Preference(\KeychainMockPreferences.testKey, preferences: "MockPreferences") var testKey
    }

    @Preference(\KeychainMockPreferences.testKey, preferences: "MockPreferences") var testKey

    private var mockPreferences: KeychainMockPreferences!
    private var keychainManager: MockKeychainManager!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        keychainManager = MockKeychainManager()
        mockPreferences = KeychainMockPreferences(keychainManager: keychainManager)
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        keychainManager = nil
        cancellables = nil
        mockPreferences = nil
        super.tearDown()
    }

    func testKeychainSaveAndLoad() throws {
        let testValue = "TestValue"

        testKey = testValue
        XCTAssertEqual(testKeyKeychainValue(), testValue)
    }

    private func testKeyKeychainValue() -> String? {
        let data = try! keychainManager.load("testKey")!
        return try? JSONDecoder().decode(String.self, from: data)
    }

    func testUserDefaultValueChangedNotification() throws {
        let testValue = "TestValue"

        let keyPath: ReferenceWritableKeyPath<KeychainMockPreferences, String?> = \.testKey
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
