import XCTest

@testable import LeezyPersistence

final class FileDataStoreTests: XCTestCase {
    private class FileMockPreferences: MockPreferences {
        @File<String, FileMockPreferences>("test.key") var testKey: String?

        var testKeyStorageKeyPath: ReferenceWritableKeyPath<FileMockPreferences, File<String, FileMockPreferences>> {
            \._testKey
        }
    }

    var store: FileDataStore!
    var key: String!

    override func setUp() {
        super.setUp()
        store = FileDataStore()
        key = "test.key"
    }

    override func tearDown() {
        store[key] = nil
        super.tearDown()
    }

    func testSetAndGetValue() throws {
        let value = "Hello"
        let data = try JSONEncoder().encode(value)
        store[key] = data

        let storedData = store[key]
        let decoded = try JSONDecoder().decode(String.self, from: storedData!)
        XCTAssertEqual(decoded, value)
    }

    func testOverwriteValue() throws {
        store[key] = try JSONEncoder().encode("First")
        store[key] = try JSONEncoder().encode("Second")

        let storedData = store[key]
        let decoded = try JSONDecoder().decode(String.self, from: storedData!)
        XCTAssertEqual(decoded, "Second")
    }

    func testRemoveValue() throws {
        store[key] = try JSONEncoder().encode("RemoveMe")
        store[key] = nil

        XCTAssertNil(store[key])
    }

    func testRemoveAll() throws {
        store[key] = try JSONEncoder().encode("Clean")
        store.removeAll()

        XCTAssertNil(store[key])
    }
}
