import Foundation

public protocol AnyPromptablePreferenceValueProvider {
    func value(
        withPrompt prompt: String,
        preferences: any PreferencesProtocol,
        keyPrefix: String?
    ) throws -> Any?
    func setValuePromptingPresence(
        _ newValue: Any?,
        withKeyPrefix keyPrefix: String?,
        using preferences: any PreferencesProtocol,
        wrappedKeyPath: AnyKeyPath
    )
}
