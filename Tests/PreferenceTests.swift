import Combine
import XCTest

@testable import LeezyPersistence

final class PreferenceTests: XCTestCase {
    private class InMemoryMockPreferences: MockPreferences {
        @InMemory<String, InMemoryMockPreferences> var testKey: String? {
            didSet {
                updatedProperty = "updated"
            }
        }

        var updatedProperty = ""

        var testKeyStorageKeyPath: ReferenceWritableKeyPath<InMemoryMockPreferences, InMemory<String, InMemoryMockPreferences>> {
            \InMemoryMockPreferences._testKey
        }
    }

    private class MockViewModel {
        @Preference(\InMemoryMockPreferences.testKey) var testKey
    }

    private var mockPreferences: InMemoryMockPreferences!

    private var updatedProperty = ""

    @Preference(\InMemoryMockPreferences.testKey) private static var testStaticKey

    @Preference(\InMemoryMockPreferences.testKey) var testKey {
        didSet {
            updatedProperty = "updated"
        }
    }

    override func setUp() {
        super.setUp()
        mockPreferences = InMemoryMockPreferences()
    }

    override func tearDown() {
        mockPreferences = nil
        super.tearDown()
    }

    func testPreferencePropertyObserver() {
        testKey = "TestValue"

        let expectedValue = "updated"
        XCTAssertEqual(updatedProperty, expectedValue)
        XCTAssertEqual(mockPreferences.updatedProperty, expectedValue)
    }

    func testStaticPreference() {
        let expectedValue = "TestValue"
        Self.testStaticKey = expectedValue

        XCTAssertEqual(Self.testStaticKey, expectedValue)
    }
}
