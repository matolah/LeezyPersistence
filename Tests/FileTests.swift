import Combine
import XCTest

@testable import LeezyPersistence

final class FileTests: XCTestCase {
    private class FileMockPreferences: MockPreferences {
        @File<String, FileMockPreferences>("test.key") var testKey: String?

        var testKeyStorageKeyPath: ReferenceWritableKeyPath<FileMockPreferences, File<String, FileMockPreferences>> {
            \._testKey
        }
    }

    private class MockViewModel {
        @Preference(\FileMockPreferences.testKey, preferences: "MockPreferences") var testKey
    }

    private var mockPreferences: FileMockPreferences!
    private var cancellables: Set<AnyCancellable>!

    @Preference(\FileMockPreferences.testKey, preferences: "MockPreferences") var testKey

    override func setUp() {
        super.setUp()
        mockPreferences = FileMockPreferences()
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        cancellables = nil
        mockPreferences = nil
        super.tearDown()
    }

    func testFileSaveAndLoad() throws {
        let testValue = "TestValue"

        testKey = testValue
        XCTAssertEqual(testKeyFileValue(), testValue)
    }

    private func testKeyFileValue() -> String? {
        let data = mockPreferences.fileDataStore["test.key"]!
        return try? JSONDecoder().decode(String.self, from: data)
    }

    func testUserDefaultValueChangedNotification() throws {
        let testValue = "TestValue"

        let keyPath: ReferenceWritableKeyPath<FileMockPreferences, String?> = \.testKey
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
