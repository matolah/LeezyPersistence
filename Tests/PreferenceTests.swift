import Combine
import XCTest

@testable import LeezyPersistence

final class PreferenceTests: XCTestCase {
    private class FileMockPreferences: MockPreferences {
        @File<Data, FileMockPreferences>("file_data") var testKey: Data? {
            didSet {
                updatedProperty = "updated"
            }
        }

        var updatedProperty = ""

        var testKeyStorageKeyPath: ReferenceWritableKeyPath<FileMockPreferences, File<Data, FileMockPreferences>> {
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
        testKey = Data()

        let expectedValue = "updated"
        XCTAssertEqual(updatedProperty, expectedValue)
        XCTAssertEqual(mockPreferences.updatedProperty, expectedValue)
    }

    func testStaticPreference() {
        let expectedValue = Data()
        Self.testStaticKey = expectedValue

        XCTAssertEqual(Self.testStaticKey, expectedValue)
    }

    func testNilDynamicPreference() {
        XCTAssertNil(_testKey["DynamicKey", provider: \FileMockPreferences.$testKey])
    }
}
