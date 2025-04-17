import Combine
import XCTest

@testable import LeezyPersistence

final class BasePreferencesTests: XCTestCase {
    private var basePreferences: BasePreferences!

    override func setUp() {
        super.setUp()
        basePreferences = BasePreferences()
    }

    override func tearDown() {
        basePreferences = nil
        super.tearDown()
    }

    func testBasePreferencesAutoRegister() {
        XCTAssertTrue(PreferencesContainer.shared.resolve(type: type(of: basePreferences)) === basePreferences)
    }
}
