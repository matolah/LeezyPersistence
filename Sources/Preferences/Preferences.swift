import Combine
import Foundation

public protocol PreferencesProtocol: AnyObject {
    var preferencesChangedSubject: PassthroughSubject<AnyKeyPath, Never> { get }
    func handle(error: Error)
}

open class BasePreferences: PreferencesProtocol {
    public private(set) var preferencesChangedSubject = PassthroughSubject<AnyKeyPath, Never>()

    public init(identifier: String) {
        PreferencesContainer.shared.register(service: self, forIdentifier: identifier)
    }

    open func handle(error: Error) {}
}
