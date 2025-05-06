import Foundation

public final class FileDataStore {
    private let baseURL: URL
    private let queue = DispatchQueue(label: "com.leezy.persistence.file.\(UUID())", attributes: .concurrent)

    public init(directory: FileManager.SearchPathDirectory = .applicationSupportDirectory, subfolder: String = "LeezyPersistence") {
        let url = FileManager.default.urls(for: directory, in: .userDomainMask).first!
        baseURL = url.appendingPathComponent(subfolder)

        try? FileManager.default.createDirectory(at: baseURL, withIntermediateDirectories: true)
    }

    public subscript(key: String) -> Data? {
        get {
            queue.sync {
                let fileURL = self.fileURL(for: key)
                return try? Data(contentsOf: fileURL)
            }
        }
        set {
            queue.async(flags: .barrier) {
                let fileURL = self.fileURL(for: key)
                if let newValue {
                    try? newValue.write(to: fileURL, options: .atomic)
                } else {
                    try? FileManager.default.removeItem(at: fileURL)
                }
            }
        }
    }

    private func fileURL(for key: String) -> URL {
        baseURL.appendingPathComponent(key + ".json")
    }

    public func removeAll() {
        queue.async(flags: .barrier) {
            try? FileManager.default.removeItem(at: self.baseURL)
            try? FileManager.default.createDirectory(at: self.baseURL, withIntermediateDirectories: true)
        }
    }
}
