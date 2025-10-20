import Foundation

public protocol AnyPromptablePreferenceValueProvider {
    func value(
        withPrompt prompt: String,
        preferences: any PreferencesProtocol,
        keyPrefix: String?
    ) throws -> Any?
}
