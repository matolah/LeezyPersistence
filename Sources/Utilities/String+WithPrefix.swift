import Foundation

extension String {
    func withPrefix(_ prefix: String) -> String {
        return "[\(prefix)] \(self)"
    }
}
