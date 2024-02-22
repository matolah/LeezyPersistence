// Created by Mateus Lino

import Combine
import XCTest

@testable import LeezyPersistence

class InMemoryTests: XCTestCase {
    fileprivate class InMemoryMockPreferences: MockPreferences {
        @InMemory<String, InMemoryMockPreferences> var testKey: String?
    }

    private var mockPreferences: InMemoryMockPreferences!
    private var cancellable: AnyCancellable?

    @Preference(\InMemoryMockPreferences.testKey, preferences: "MockPreferences") var testKey

    override func setUp() {
        super.setUp()
        mockPreferences = InMemoryMockPreferences()
    }

    override func tearDown() {
        cancellable = nil
        mockPreferences = nil
        super.tearDown()
    }

    func testInMemorySaveAndLoad() throws {
        let testValue = "TestValue"

        testKey = testValue
        XCTAssertEqual(testKeyInMemoryValue(), testValue)
    }

    private func testKeyInMemoryValue() -> String? {
        let data = mockPreferences.inMemoryDataStore.first!.value
        return try? JSONDecoder().decode(String.self, from: data)
    }

    func testUserDefaultValueChangedNotification() throws {
        let testValue = "TestValue"

        let keyPath: ReferenceWritableKeyPath<InMemoryMockPreferences, String?> = \.testKey
        cancellable = mockPreferences.preferencesChangedSubject
            .sink { changedKeyPath in
                XCTAssertTrue(changedKeyPath == keyPath)
            }

        testKey = testValue
    }
}

