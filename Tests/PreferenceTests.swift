import Combine
import XCTest

@testable import LeezyPersistence

final class PreferenceTests: XCTestCase {
    private class FileMockPreferences: MockPreferences {
        @File<String, FileMockPreferences>("test") var testKey: String? {
            didSet {
                updatedProperty = "updated"
            }
        }

        var updatedProperty = ""

        var testKeyStorageKeyPath: ReferenceWritableKeyPath<FileMockPreferences, File<String, FileMockPreferences>> {
            \FileMockPreferences._testKey
        }
    }

    private class MockViewModel {
        @Preference(\FileMockPreferences.testKey) var testKey
    }

    private var mockPreferences: FileMockPreferences!

    private var updatedProperty = ""

    @Preference(\FileMockPreferences.testKey) private static var testStaticKey

    @Preference(\FileMockPreferences.testKey) var testKey {
        didSet {
            updatedProperty = "updated"
        }
    }

    override func setUp() {
        super.setUp()
        mockPreferences = FileMockPreferences()
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

    func testNilDynamicPreference() {
        let dynamicKey = "DynamicKey"
        _testKey[dynamicKey] = "Test"
        _testKey[dynamicKey] = nil

        XCTAssertNil(_testKey[dynamicKey])
    }
}
