// Created by Mateus Lino

import Combine
import XCTest

@testable import LeezyPersistence

class InMemoryTests: XCTestCase {
    fileprivate class InMemoryMockPreferences: MockPreferences {
        @InMemory<String, InMemoryMockPreferences> var testKey: String?
    }

    fileprivate class Container {
        @Preference(\InMemoryMockPreferences.testKey, preferences: "MockPreferences") var testKey
    }

    private var container: Container!
    private var mockPreferences: InMemoryMockPreferences!
    private var cancellable: AnyCancellable?

    override func setUp() {
        super.setUp()
        mockPreferences = InMemoryMockPreferences()
        container = Container()
    }

    override func tearDown() {
        cancellable = nil
        mockPreferences = nil
        container = nil
        super.tearDown()
    }

    func testInMemorySaveAndLoad() throws {
        let testValue = "TestValue"

        container.testKey = testValue
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

        container.testKey = testValue
    }
}

