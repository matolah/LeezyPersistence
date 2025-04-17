import Combine
import Foundation

/// A protocol that defines the contract for managing persistent preferences in an application.
///
/// ## Single Instance Requirement
/// Preferences types conforming to this protocol must maintain a single shared instance throughout
/// the application's lifecycle. This requirement ensures consistency in preference management and
/// prevents potential conflicts that could arise from multiple instances managing the same preferences.
///
/// Example implementation:
/// ```swift
/// final class AppPreferences: BasePreferences {
///     @UserDefault("user_name") var userName: String?
/// }
/// ```
///
/// ## Thread Safety
/// The preferences container automatically handles thread-safe access to preference values,
/// allowing you to safely read and write preferences from different threads.
public protocol PreferencesProtocol: AnyObject {
    var preferencesChangedSubject: PassthroughSubject<AnyKeyPath, Never> { get }
    func handle(error: Error)
}

open class BasePreferences: PreferencesProtocol {
    public private(set) var preferencesChangedSubject = PassthroughSubject<AnyKeyPath, Never>()

    public init() {
        PreferencesContainer.shared.register(preferences: self)
    }

    open func handle(error: Error) {}
}
