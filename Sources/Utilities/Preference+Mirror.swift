import Foundation

extension Preference {
    /// Resolves the underlying property wrapper instance backing the provided key path.
    ///
    /// This method uses Swift's runtime reflection to access the synthesized storage variable
    /// (e.g., `_propertyName`) behind a `@Preference` declaration. It is useful for advanced scenarios
    /// such as dynamically retrieving values from the storage wrapper (e.g., `File`, `Keychain`)
    /// based on runtime logic like key prefixing.
    ///
    /// ⚠️ **Warning:** This relies on Swift’s internal naming convention for synthesized
    /// property wrappers (`_propertyName`). It may break if Swift’s rules change, or if
    /// the wrapper is not properly stored with a leading underscore.
    ///
    /// - Returns: The property wrapper instance, or `nil` if not found.
    func resolvePropertyWrapper() -> Any? {
        let underscoredLabel = "_\(labelForKeyPath(keyPath))"
        let mirror = Mirror(reflecting: preferences)

        let child = mirror.children.first { child in
            child.label == underscoredLabel
        }
        guard let wrapper = child?.value else {
            assertionFailure(
                "No property wrapper found for `\(underscoredLabel)` in \(Preferences.self). " +
                "This relies on Swift's underscored property wrapper naming convention."
            )
            return nil
        }
        return wrapper
    }

    private func labelForKeyPath(_ keyPath: ReferenceWritableKeyPath<Preferences, Value?>) -> String {
        String(describing: keyPath)
            .components(separatedBy: ".")
            .last ?? "unknown"
    }
}
