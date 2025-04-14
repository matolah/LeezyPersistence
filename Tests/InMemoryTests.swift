import Combine
import XCTest

@testable import LeezyPersistence

class InMemoryTests: XCTestCase {
    private class InMemoryMockPreferences: MockPreferences {
        @InMemory<String, InMemoryMockPreferences> var testKey: String?

        var testKeyStorageKeyPath: ReferenceWritableKeyPath<InMemoryMockPreferences, InMemory<String, InMemoryMockPreferences>> {
            \InMemoryMockPreferences._testKey
        }
    }

    private class MockViewModel {
        @Preference(\InMemoryMockPreferences.testKey, preferences: "MockPreferences") var testKey
    }

    private var mockPreferences: InMemoryMockPreferences!
    private var cancellables: Set<AnyCancellable>!

    @Preference(\InMemoryMockPreferences.testKey, preferences: "MockPreferences") var testKey

    override func setUp() {
        super.setUp()
        mockPreferences = InMemoryMockPreferences()
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        cancellables = nil
        mockPreferences = nil
        super.tearDown()
    }

    func testInMemorySaveAndLoad() throws {
        let testValue = "TestValue"

        testKey = testValue
        XCTAssertEqual(testKeyInMemoryValue(), testValue)
    }

    private func testKeyInMemoryValue() -> String? {
        let data = mockPreferences.inMemoryDataStore[mockPreferences.testKeyStorageKeyPath]!
        return try? JSONDecoder().decode(String.self, from: data)
    }

    func testUserDefaultValueChangedNotification() throws {
        let testValue = "TestValue"

        let keyPath: ReferenceWritableKeyPath<InMemoryMockPreferences, String?> = \.testKey
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
