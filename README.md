<a name="readme-top"></a>

<div align="center">
  <h3 align="center">LeezyPersistence</h3>
  
  <p align="center">
    Type-safe data persistence in Swift made simple - with built-in support for UserDefaults, Keychain, in-memory, and file-based storage.
    <br />
    <a href="https://github.com/matolah/LeezyPersistence/issues">Report Bug</a>
    ·
    <a href="https://github.com/matolah/LeezyPersistence/issues">Request Feature</a>
  </p>
</div>

## What is LeezyPersistence?

**LeezyPersistence** is a lightweight, type-safe persistence library for Swift.  
It provides intuitive property wrappers for saving and retrieving values from:

- 🧠 **In-memory storage** - fast and temporary
- 🗂️ **UserDefaults** - for lightweight app preferences
- 🔐 **Keychain** - for securely storing sensitive values like tokens
- 📁 **File-based storage** - for custom JSON-encoded persistence

No need to manage different APIs - just use one unified, clean interface.

Inspired by [this article on AppStorage](https://www.avanderlee.com/swift/appstorage-explained).

## Installation

Add `LeezyPersistence` to your project using **Swift Package Manager**:

```swift
dependencies: [
    .package(url: "https://github.com/matolah/LeezyPersistence.git", .upToNextMajor(from: "1.0.0"))
]
```

## Usage

1. Create your preferences class

```swift
final class SharedPreferences: BasePreferences, KeychainPreferences, UserDefaultPreferences {
    let keychainManager: KeychainManagerProtocol
    let userDefaults: UserDefaults

    @UserDefault<Bool, SharedPreferences>("hasSeenTutorial") var hasSeenTutorial: Bool?

    @Keychain<String, SharedPreferences>("accessToken") var accessToken: String?

    @InMemory<Int, SharedPreferences> var cachedPage: Int?

    @File<[String], SharedPreferences>("history.json") var savedHistory: [String]?

    init(keychainManager: KeychainManagerProtocol, userDefaults: UserDefaults) {
      self.keychainManager = keychainManager
      self.userDefaults = userDefaults
      super.init()
    }

    override func handle(error: Error) {
        print("Error: \(error)")
    }
}
```

2. Register it

```swift
@main
struct MyApp: App {
    init() {
        sharedPreferences = SharedPreferences(
            keychainManager: MyKeychainManager(),
            userDefaults: .standard
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

3. Access preferences with `@Preference`

```swift
final class ContentViewModel: ObservableObject {
    private let userID: String

    @Published var isInHomePage = false

    @Preference(\SharedPreferences.hasSeenTutorial) var hasSeenTutorial

    @Preference(\SharedPreferences.accessToken) var accessToken

    private var cancellables = Set<AnyCancellable>()

    init(userID: String) {
        self.userID = userID
        _accessToken.subscribe(storingTo: &cancellables) { [weak self] _ in
            guard let self, self.hasSeenTutorial == true else { 
                return 
            }
            self.isInHomePage = true
        }
    }

    func markTutorialAsSeen() {
      // Access user-specific `Preference` using a dynamic key
      hasSeenTutorial[userID] = true
    }
}
```

4. Create as many `Preferences` classes with context-specific preferences as you'd like:

```swift
final class OnboardingPreferences: BasePreferences {
    let keychainManager: KeychainManagerProtocol

    @Keychain<String, OnboardingPreferences>("accessToken") var accessToken: String?

    init(keychainManager: KeychainManagerProtocol) {
      self.keychainManager = keychainManager
      super.init()
    }

    override func handle(error: Error) {
        print("Error: \(error)")
    }
}
```

## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

## 🤝 Contributing

Contributions are welcome!
If you have suggestions for improvements, bug fixes, or new features, feel free to open an issue or submit a pull request.

## 💬 Contact

Maintained by @_matolah
