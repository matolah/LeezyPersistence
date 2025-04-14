import Foundation

enum PropertyWrapperFailures {
    static func wrappedValueAssertionFailure() {
        assertionFailure("Accessing wrappedValue directly is unsupported. Use _enclosingInstance instead.")
    }
}
