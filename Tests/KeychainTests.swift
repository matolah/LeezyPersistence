import Combine
import XCTest

@testable import LeezyPersistence

final class KeychainTests: XCTestCase {
    private class KeychainMockPreferences: MockPreferences {
        @Keychain<String, KeychainMockPreferences>("testKey") var testKey: String?

        override init(
            keychainManager: KeychainManagerProtocol,
            userDefaults: UserDefaults = UserDefaults.standard
        ) {
            super.init(keychainManager: keychainManager, userDefaults: userDefaults)
        }
    }

    private class MockViewModel {
        @Preference(\KeychainMockPreferences.testKey) var testKey
    }

    @Preference(\KeychainMockPreferences.testKey) var testKey
    @ProtectedPreference(\KeychainMockPreferences.testKey) var testPromptKey

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
        XCTAssertNil(keychainManager.promptMessagePassed)
    }

    private func testKeyKeychainValue() -> String? {
        guard let data = try! keychainManager.load("testKey", withPromptMessage: nil) else {
            return nil
        }
        return try? JSONDecoder().decode(String.self, from: data)
    }

    func testDyamicKeyKeychainSaveAndLoad() throws {
        let testValue = "testValue"
        let testDynamicValue = "testDynamicValue"

        testKey = testValue
        _testKey["testDynamicKey", provider: \KeychainMockPreferences.$testKey] = testDynamicValue
        let value = try? JSONDecoder().decode(String.self, from: try! keychainManager.load("[testDynamicKey] testKey", withPromptMessage: nil)!)
        XCTAssertEqual(value, testDynamicValue)
        XCTAssertEqual(testKeyKeychainValue(), testValue)
    }

    func testKeychainValueWithPrompt() throws {
        let testValue = "TestValue"

        testKey = testValue
        switch _testPromptKey["Prompt"] {
        case .success(let value):
            XCTAssertEqual(value, testValue)
        case .failure:
            XCTFail("Failed to resolve Keychain protected value")
        }
        XCTAssertEqual(keychainManager.promptMessagePassed, "Prompt")
    }

    func testKeychainValueWithPromptAndError() throws {
        keychainManager.error = NSError()
        switch _testPromptKey["Prompt"] {
        case .success:
            XCTFail("Failed to resolve Keychain protected value")
        case .failure:
            return
        }
        XCTAssertEqual(keychainManager.promptMessagePassed, "Prompt")
    }

    func testKeychainValueChangedNotification() throws {
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
