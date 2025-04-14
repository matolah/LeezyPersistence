import XCTest

@testable import LeezyPersistence

final class InMemoryDataStoreTests: XCTestCase {
    fileprivate class InMemoryMockPreferences: MockPreferences {
        @InMemory<String, InMemoryMockPreferences> var testKey: String?

        var testKeyStorageKeyPath: ReferenceWritableKeyPath<InMemoryMockPreferences, InMemory<String, InMemoryMockPreferences>> {
            \InMemoryMockPreferences._testKey
        }
    }

    var store: InMemoryDataStore!
    var keyPath: AnyKeyPath!

    override func setUp() {
        super.setUp()
        store = InMemoryDataStore()
        keyPath = \InMemoryMockPreferences.testKeyStorageKeyPath
    }

    func testSetAndGetValue() throws {
        let value = "Hello"
        let data = try JSONEncoder().encode(value)
        store[keyPath] = data

        let storedData = store[keyPath]
        let decoded = try? JSONDecoder().decode(String.self, from: storedData!)
        XCTAssertEqual(decoded, value)
    }

    func testOverwriteValue() throws {
        let first = try JSONEncoder().encode("First")
        let second = try JSONEncoder().encode("Second")

        store[keyPath] = first
        store[keyPath] = second

        let storedData = store[keyPath]
        let decoded = try? JSONDecoder().decode(String.self, from: storedData!)
        XCTAssertEqual(decoded, "Second")
    }

    func testRemoveValue() throws {
        let value = try JSONEncoder().encode("ToRemove")
        store[keyPath] = value
        store.removeValue(forKey: keyPath)

        let data = store[keyPath]
        XCTAssertNil(data)
    }

    func testRemoveAll() throws {
        let value = try JSONEncoder().encode("Clean")
        store[keyPath] = value

        store.removeAll()
        let data = store[keyPath]
        XCTAssertNil(data)
    }

    func testContainsKey() throws {
        XCTAssertFalse(store.contains(keyPath))

        let value = try JSONEncoder().encode("Check")
        store[keyPath] = value

        XCTAssertTrue(store.contains(keyPath))
    }
}
