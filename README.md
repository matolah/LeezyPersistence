<a name="readme-top"></a>

<div align="center">
  <h3 align="center">LeezyPersistence</h3>

  <p align="center">
    <a href="https://github.com/matolah/LeezyPersistence/issues">Report Bug</a>
    ·
    <a href="https://github.com/matolah/LeezyPersistence/issues">Request Feature</a>
  </p>
</div>

Elevate your `Swift` data management with an effortless `UserDefaults`, `Keychain`, and in-memory storage solution.
- [About](#about)
- [Installation](#installation)
- [Usage](#usage)
- [License](#license)
- [Contact](#contact)

## About

This package streamlines Swift data persistence, blending `UserDefaults`, `Keychain`, and in-memory solutions into a cohesive, type-safe package. 

Designed to maximize developer convenience and code clarity, it introduces intuitive property wrappers that abstract complex storage operations. Whether securing sensitive information in the `Keychain`, storing user preferences, or caching data in memory, `LeezyPersistence` enhances your application's storage capabilities with minimal setup and maximum efficiency.


## Installation

`LeezyPersistence` is available for installation via SPM:

```swift
dependencies: [
    .package(url: "https://github.com/matolah/LeezyPersistence.git", .upToNextMajor(from: "1.0.0"))
]
```


## Usage

Create as many `Preferences` classes with context-specific preferences as you'd like:

```swift
final class SharedPreferences: BasePreferences {
    @UserDefault<Bool, SharedPreferences>("hasSeenTutorial") var hasSeenTutorial: Bool?

    override func handle(error: Error) {
        print("Error: \(error)")
    }
}

final class OnboardingPreferences: BasePreferences {
    @Keychain<String, OnboardingPreferences>("accessToken") var accessToken: String?

    override func handle(error: Error) {
        print("Error: \(error)")
    }
}
```

Create instances of them with custom identifiers:

```swift
enum PreferencesIdentifier: String {
    case shared
    case onboarding
}

@main
struct SafeDrinkApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    init() {
        sharedPreferences = SharedPreferences(
            identifier: PreferencesIdentifier.shared.rawValue,
            keychainManager: MyKeychainManager(),
            userDefaults: .standard
        )
        onboardingPreferences = OnboardingPreferences(
            identifier: PreferencesIdentifier.onboarding.rawValue,
            keychainManager: MyKeychainManager(),
            userDefaults: .standard
        )
    }
}
```

Use them in your classes:

```swift
final class ContentViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()

    @Published var isInHomePage = false

    @Preference(\SharedPreferences.hasSeenTutorial, preferences: PreferencesIdentifier.shared.rawValue) var hasSeenTutorial
    @Preference(\OnboardingPreferences.accessToken, preferences: PreferencesIdentifier.onboarding.rawValue) var accessToken

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        setUpInputs()
    }

    private func setUpInputs() {
        _accessToken.subscribe(storingTo: &cancellables) { [weak self] _ in
            guard let self, self.hasSeenTutorial == true else {
                return
            }
            self.isInHomePage = true
            self.objectWillChange.send()
        }
    }
}
```


## License

Distributed under the MIT License. See `LICENSE.txt` for more information.


## Contact

Twitter: [@_matolah](https://twitter.com/_matolah)
