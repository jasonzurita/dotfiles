---
name: new-swift-app
description: Scaffolds a new Swift/iOS app's SPM module architecture — creates the modules/ directory, Package.swift, foundational modules (App, Model, Design, World, BasicClients), and a project CLAUDE.md.
allowed-tools: Read, Write, Edit, Bash
---

Scaffold a new Swift/iOS app's SPM module architecture using the composition-tree pattern.

## 1. Gather information

Ask the user for the following (skip any already provided):

- **Project spec** — the app's design/product spec. Accept it as either: pasted text inline, or a file path to read. If the user has a spec, read it fully before proceeding — it drives the CLAUDE.md content. Optional, but highly recommended.
- **App name** — e.g. `My Cool App`
- **Module prefix** — 2–3 uppercase letters, unique to this project. Used on all SPM product names (e.g. `MC` → `MCApp`, `MCModel`). BasicClients omit the prefix.
- **iOS deployment target** — minimum iOS version (default: `18`)
- **Initial features** — zero or more feature names to scaffold immediately (e.g. `Home`, `Settings`). If a spec was provided, suggest feature names derived from it and confirm with the user.
- **Short app description** — one sentence summary. If a spec was provided, derive this from it.

Do not proceed until you have at minimum: app name and module prefix.

Derive a safe Swift identifier from the app name for use in file/module names: strip spaces and special characters, PascalCase the result. Example: `My Cool App` → `MyCoolApp`. This is used as the `Package(name:)` value.

---

## 2. Create directory structure

Create all the following directories (use `mkdir -p`). Replace `<PREFIX>` and feature names appropriately.

```
modules/
modules/Modules/
modules/Modules/App/src/
modules/Modules/App/Tests/
modules/Modules/Model/src/
modules/Modules/Model/Tests/
modules/Modules/Design/src/
modules/Modules/World/src/
modules/Modules/BasicClients/ApplicationClient/src/
modules/Modules/BasicClients/FileManagerClient/src/
modules/Modules/BasicClients/UserDefaultsClient/src/
TestPlans/
```

For each initial feature (if any):
```
modules/Modules/Features/<FeatureName>/src/
modules/Modules/Features/<FeatureName>/Tests/
```

---

## 3. Create Package.swift

Create `modules/Package.swift`. Substitute `<SWIFT_ID>` (the derived Swift identifier), `<PREFIX>`, `<IOS_VERSION>`, and feature targets.

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "<SWIFT_ID>",
    platforms: [.iOS(.<IOS_VERSION>)],
    products: [
        .library(name: "<PREFIX>App", targets: ["<PREFIX>App"]),
        .library(name: "<PREFIX>Model", targets: ["<PREFIX>Model"]),
        .library(name: "<PREFIX>Design", targets: ["<PREFIX>Design"]),
        .library(name: "<PREFIX>World", targets: ["<PREFIX>World"]),
        .library(name: "ApplicationClient", targets: ["ApplicationClient"]),
        .library(name: "FileManagerClient", targets: ["FileManagerClient"]),
        .library(name: "UserDefaultsClient", targets: ["UserDefaultsClient"]),
        // <FEATURE_PRODUCTS>
    ],
    targets: [

        // MARK: - App

        .target(
            name: "<PREFIX>App",
            dependencies: [
                "<PREFIX>Model",
                "<PREFIX>Design",
                "<PREFIX>World",
                // <FEATURE_DEPS>
            ],
            path: "Modules/App/src"
        ),
        .testTarget(
            name: "<PREFIX>AppTests",
            dependencies: ["<PREFIX>App"],
            path: "Modules/App/Tests"
        ),

        // MARK: - Model

        .target(
            name: "<PREFIX>Model",
            path: "Modules/Model/src"
        ),
        .testTarget(
            name: "<PREFIX>ModelTests",
            dependencies: ["<PREFIX>Model"],
            path: "Modules/Model/Tests"
        ),

        // MARK: - Design

        .target(
            name: "<PREFIX>Design",
            dependencies: ["<PREFIX>Model"],
            path: "Modules/Design/src"
        ),

        // MARK: - World

        .target(
            name: "<PREFIX>World",
            dependencies: [
                "ApplicationClient",
                "FileManagerClient",
                "UserDefaultsClient",
            ],
            path: "Modules/World/src"
        ),

        // MARK: - BasicClients

        .target(
            name: "ApplicationClient",
            path: "Modules/BasicClients/ApplicationClient/src"
        ),
        .target(
            name: "FileManagerClient",
            path: "Modules/BasicClients/FileManagerClient/src"
        ),
        .target(
            name: "UserDefaultsClient",
            path: "Modules/BasicClients/UserDefaultsClient/src"
        ),

        // MARK: - Features
        // <FEATURE_TARGETS>
    ]
)
```

For each initial feature named `<Feature>`, add:
- To products: `.library(name: "<PREFIX><Feature>", targets: ["<PREFIX><Feature>"])`
- To `<PREFIX>App` dependencies: `"<PREFIX><Feature>"`
- To targets:
```swift
.target(
    name: "<PREFIX><Feature>",
    dependencies: ["<PREFIX>Model", "<PREFIX>Design"],
    path: "Modules/Features/<Feature>/src"
),
.testTarget(
    name: "<PREFIX><Feature>Tests",
    dependencies: ["<PREFIX><Feature>"],
    path: "Modules/Features/<Feature>/Tests"
),
```

---

## 4. Create BasicClient modules

Create the following files. Use the exact struct-of-closures pattern: explicit `public init`, no default values in the struct definition, `@Sendable` on all closures.

### ApplicationClient

**`modules/Modules/BasicClients/ApplicationClient/src/Interface.swift`**
```swift
import Foundation
import UIKit

public struct ApplicationClient: Sendable {
    public var appVersion: @Sendable () -> String
    public var buildNumber: @Sendable () -> String
    public var openURL: @MainActor (URL) -> Void

    public init(
        appVersion: @escaping @Sendable () -> String,
        buildNumber: @escaping @Sendable () -> String,
        openURL: @escaping @MainActor (URL) -> Void
    ) {
        self.appVersion = appVersion
        self.buildNumber = buildNumber
        self.openURL = openURL
    }
}
```

**`modules/Modules/BasicClients/ApplicationClient/src/Live.swift`**
```swift
import UIKit

public extension ApplicationClient {
    static func live() -> Self {
        .init(
            appVersion: {
                Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
            },
            buildNumber: {
                Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
            },
            openURL: { url in
                UIApplication.shared.open(url)
            }
        )
    }
}
```

**`modules/Modules/BasicClients/ApplicationClient/src/Mocks.swift`**
```swift
public extension ApplicationClient {
    static func mock(
        appVersion: @escaping @Sendable () -> String = { "1.0" },
        buildNumber: @escaping @Sendable () -> String = { "1" },
        openURL: @escaping @MainActor (URL) -> Void = { _ in }
    ) -> Self {
        .init(
            appVersion: appVersion,
            buildNumber: buildNumber,
            openURL: openURL
        )
    }

    static func happyPath() -> Self { .mock() }
}
```

### FileManagerClient

**`modules/Modules/BasicClients/FileManagerClient/src/Interface.swift`**
```swift
import Foundation

public struct FileManagerClient: Sendable {
    public var url: @Sendable (FileManager.SearchPathDirectory, FileManager.SearchPathDomainMask, URL?, Bool) throws -> URL
    public var fileExists: @Sendable (_ atPath: String) -> Bool
    public var createDirectory: @Sendable (URL, Bool, [FileAttributeKey: Any]?) throws -> Void
    public var contentsOfDirectory: @Sendable (URL, [URLResourceKey]?, FileManager.DirectoryEnumerationOptions) throws -> [URL]
    public var removeItem: @Sendable (URL) throws -> Void

    public init(
        url: @escaping @Sendable (FileManager.SearchPathDirectory, FileManager.SearchPathDomainMask, URL?, Bool) throws -> URL,
        fileExists: @escaping @Sendable (String) -> Bool,
        createDirectory: @escaping @Sendable (URL, Bool, [FileAttributeKey: Any]?) throws -> Void,
        contentsOfDirectory: @escaping @Sendable (URL, [URLResourceKey]?, FileManager.DirectoryEnumerationOptions) throws -> [URL],
        removeItem: @escaping @Sendable (URL) throws -> Void
    ) {
        self.url = url
        self.fileExists = fileExists
        self.createDirectory = createDirectory
        self.contentsOfDirectory = contentsOfDirectory
        self.removeItem = removeItem
    }
}
```

**`modules/Modules/BasicClients/FileManagerClient/src/Live.swift`**
```swift
import Foundation

public extension FileManagerClient {
    static func live() -> Self {
        .init(
            url: { FileManager.default.url(for: $0, in: $1, appropriateFor: $2, create: $3) },
            fileExists: { FileManager.default.fileExists(atPath: $0) },
            createDirectory: { try FileManager.default.createDirectory(at: $0, withIntermediateDirectories: $1, attributes: $2) },
            contentsOfDirectory: { try FileManager.default.contentsOfDirectory(at: $0, includingPropertiesForKeys: $1, options: $2) },
            removeItem: { try FileManager.default.removeItem(at: $0) }
        )
    }
}
```

**`modules/Modules/BasicClients/FileManagerClient/src/Mocks.swift`**
```swift
import Foundation

public extension FileManagerClient {
    static func mock(
        url: @escaping @Sendable (FileManager.SearchPathDirectory, FileManager.SearchPathDomainMask, URL?, Bool) throws -> URL = { _, _, _, _ in URL(filePath: "/tmp") },
        fileExists: @escaping @Sendable (String) -> Bool = { _ in false },
        createDirectory: @escaping @Sendable (URL, Bool, [FileAttributeKey: Any]?) throws -> Void = { _, _, _ in },
        contentsOfDirectory: @escaping @Sendable (URL, [URLResourceKey]?, FileManager.DirectoryEnumerationOptions) throws -> [URL] = { _, _, _ in [] },
        removeItem: @escaping @Sendable (URL) throws -> Void = { _ in }
    ) -> Self {
        .init(
            url: url,
            fileExists: fileExists,
            createDirectory: createDirectory,
            contentsOfDirectory: contentsOfDirectory,
            removeItem: removeItem
        )
    }

    static func happyPath() -> Self { .mock() }
}
```

### UserDefaultsClient

**`modules/Modules/BasicClients/UserDefaultsClient/src/Interface.swift`**
```swift
import Foundation

public struct UserDefaultsClient: Sendable {
    public var string: @Sendable (_ forKey: String) -> String?
    public var setString: @Sendable (String, _ forKey: String) -> Void
    public var bool: @Sendable (_ forKey: String) -> Bool
    public var setBool: @Sendable (Bool, _ forKey: String) -> Void
    public var removeObject: @Sendable (_ forKey: String) -> Void

    public init(
        string: @escaping @Sendable (String) -> String?,
        setString: @escaping @Sendable (String, String) -> Void,
        bool: @escaping @Sendable (String) -> Bool,
        setBool: @escaping @Sendable (Bool, String) -> Void,
        removeObject: @escaping @Sendable (String) -> Void
    ) {
        self.string = string
        self.setString = setString
        self.bool = bool
        self.setBool = setBool
        self.removeObject = removeObject
    }
}
```

**`modules/Modules/BasicClients/UserDefaultsClient/src/Live.swift`**
```swift
import Foundation

public extension UserDefaultsClient {
    static var live: Self {
        .init(
            string: { UserDefaults.standard.string(forKey: $0) },
            setString: { UserDefaults.standard.set($0, forKey: $1) },
            bool: { UserDefaults.standard.bool(forKey: $0) },
            setBool: { UserDefaults.standard.set($0, forKey: $1) },
            removeObject: { UserDefaults.standard.removeObject(forKey: $0) }
        )
    }
}
```

**`modules/Modules/BasicClients/UserDefaultsClient/src/Mocks.swift`**
```swift
import Foundation

public extension UserDefaultsClient {
    static func mock(
        string: @escaping @Sendable (String) -> String? = { _ in nil },
        setString: @escaping @Sendable (String, String) -> Void = { _, _ in },
        bool: @escaping @Sendable (String) -> Bool = { _ in false },
        setBool: @escaping @Sendable (Bool, String) -> Void = { _, _ in },
        removeObject: @escaping @Sendable (String) -> Void = { _ in }
    ) -> Self {
        .init(
            string: string,
            setString: setString,
            bool: bool,
            setBool: setBool,
            removeObject: removeObject
        )
    }

    static func happyPath() -> Self { .mock() }
}
```

---

## 5. Create World module

**`modules/Modules/World/src/World.swift`**

Replace `<PREFIX>` with the module prefix.

```swift
import ApplicationClient
import FileManagerClient
import Foundation
import UserDefaultsClient

public let Current: World = .live()

public struct World: Sendable {
    public var currentDate: @Sendable () -> Date
    public var applicationClient: ApplicationClient
    public var fileManagerClient: FileManagerClient
    public var userDefaultsClient: UserDefaultsClient

    public init(
        currentDate: @escaping @Sendable () -> Date,
        applicationClient: ApplicationClient,
        fileManagerClient: FileManagerClient,
        userDefaultsClient: UserDefaultsClient
    ) {
        self.currentDate = currentDate
        self.applicationClient = applicationClient
        self.fileManagerClient = fileManagerClient
        self.userDefaultsClient = userDefaultsClient
    }
}

extension World {
    static func live() -> World {
        .init(
            currentDate: Date.init,
            applicationClient: .live(),
            fileManagerClient: .live(),
            userDefaultsClient: .live
        )
    }
}
```

---

## 6. Create Model module placeholder

**`modules/Modules/Model/src/Placeholder.swift`**
```swift
// Add your Codable domain model types here.
// Each type gets its own file (e.g. User.swift, Item.swift).
```

---

## 7. Create Design module placeholder

**`modules/Modules/Design/src/Placeholder.swift`**
```swift
// Add shared design tokens and UI components here.
// Suggested starting files:
//   - Colors.swift       (Color extensions or named color constants)
//   - Typography.swift   (Font extensions or text style constants)
//   - Spacing.swift      (CGFloat spacing constants)
```

---

## 8. Create App module

### AppRootViewModel

**`modules/Modules/App/src/AppRootViewModel.swift`**

Replace `<PREFIX>` with the module prefix.

```swift
import <PREFIX>World
import Foundation
import Observation

@Observable
@MainActor
public final class AppRootViewModel {
    public init() {
        // Initialize app state using World and injected clients.
        // Expand this as your app grows.
    }
}
```

### AppRootView

**`modules/Modules/App/src/AppRootView.swift`**

Replace `<APP_NAME>` with the human-readable app name and `<PREFIX>` with the module prefix.

```swift
import <PREFIX>Design
import SwiftUI

public struct AppRootView: View {
    private var viewModel: AppRootViewModel

    public init(viewModel: AppRootViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Text("<APP_NAME>")
    }
}

#Preview {
    AppRootView(viewModel: AppRootViewModel())
}
```

---

## 9. Create initial feature modules

For each feature the user listed, create the following files. Replace `<Feature>` with the feature name and `<PREFIX>` with the module prefix.

### FeatureViewModel

**`modules/Modules/Features/<Feature>/src/<Feature>ViewModel.swift`**
```swift
import <PREFIX>Model
import Foundation
import Observation

@Observable
public final class <Feature>ViewModel {
    public init() {}
}

extension <Feature>ViewModel {
    static var mock: Self { .init() }
}
```

### FeatureView

**`modules/Modules/Features/<Feature>/src/<Feature>View.swift`**
```swift
import SwiftUI

public struct <Feature>View: View {
    private var viewModel: <Feature>ViewModel

    public init(viewModel: <Feature>ViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Text("<Feature>")
    }
}

#Preview {
    <Feature>View(viewModel: .mock)
}
```

---

## 10. Create project CLAUDE.md

Create `CLAUDE.md` in the project root. The content depends on whether a project spec was provided:

### If a spec was provided

Synthesize a full CLAUDE.md by reading the spec carefully and extracting:

- **App description** — what the app is and who it is for (1–3 sentences, from the spec)
- **Domain Vocabulary** — every domain-specific noun the spec uses that a developer would need to understand (e.g. "Match", "Season", "Formation"). Build a Markdown table: Term | Meaning. Include every concept that is not obvious from its name alone. If the spec mentions a data object, UI concept, or process by a specific name, it belongs here.
- **Data Persistence** — what data the app needs to store and how. Describe the on-disk layout (directory structure, file formats, one-file-per-record vs. single file, etc.) based on what the spec implies. If the spec does not specify storage details, note what will need to be decided.
- **Subscription & Paywall** — if the spec mentions a free tier, paid tier, or feature gating, capture that here. Note which features are free vs. paid and what the paywall model is. If not mentioned, omit this section.
- **Key Decisions & Constraints** — any non-obvious technical or product constraints from the spec: offline-first, platform target (iPad-first, iPhone-only, etc.), third-party dependencies required, performance requirements, accessibility requirements, etc.
- **Features** — list the initial feature modules and a one-line description of each, drawn from the spec.

Use this structure (omit sections that have no content from the spec):

```markdown
# <APP_NAME>

<APP_DESCRIPTION>

App Store: (add when published)
Website: (add when published)

---

## Build & Workspace

- Open `<APP_NAME>.xcworkspace` (use this, not the `.xcodeproj` directly)
- Primary scheme: **<APP_NAME>**
- Swift Package dependencies live under `modules/`
- Test plans live in `TestPlans/` — one `.xctestplan` per module

## Running Tests

xcodebuild test \
  -workspace <APP_NAME>.xcworkspace \
  -scheme <APP_NAME> \
  -testPlan <PlanName> \
  -destination 'platform=iOS Simulator,name=iPad Air 11-inch (M3)'

## Module Architecture

<composition tree using actual PREFIX and feature names>

## Module Naming Convention

All products and targets use the `<PREFIX>` prefix. BasicClients omit the prefix.

## Dependency Injection

Dependencies use the struct-of-closures (client) pattern. Use `/create-swift-client` to scaffold new clients.

The `World` global holds broadly-needed system abstractions. Add to `World` only if 3+ modules need the same client directly.

## State Management

Default: `@Observable` MVVM. Use an action-based reducer for features with complex, interdependent state transitions.

## Testing

Tests are mandatory for all feature work and bug fixes. Each module has a `.testTarget` in `Package.swift` and a `.xctestplan` in `TestPlans/`.

## Domain Vocabulary

| Term | Meaning |
|------|---------|
| <extracted from spec> | ... |

## Data Persistence

<describe on-disk layout implied by the spec>

## Subscription & Paywall (if applicable)

<free vs. paid features, paywall model>

## Key Conventions

- **One type per file** — even small helpers
- **No default parameter values** unless there is a clear, obvious reason
- **Constants must be `private`** unless part of a public interface
- **No `TODO` comments in committed code** — use GitHub issues instead
<any additional constraints from the spec>
```

### If no spec was provided

Create the CLAUDE.md with the structural sections filled in from the gathered inputs (app name, prefix, iOS version, features), and leave Domain Vocabulary, Data Persistence, and Subscription sections as clearly marked placeholders for the user to fill in:

```markdown
# <APP_NAME>

<SHORT_DESCRIPTION>

---

## Build & Workspace

- Open `<APP_NAME>.xcworkspace` (use this, not the `.xcodeproj` directly)
- Primary scheme: **<APP_NAME>**
- Swift Package dependencies live under `modules/`
- Test plans live in `TestPlans/` — one `.xctestplan` per module

## Running Tests

xcodebuild test \
  -workspace <APP_NAME>.xcworkspace \
  -scheme <APP_NAME> \
  -testPlan <PlanName> \
  -destination 'platform=iOS Simulator,name=iPad Air 11-inch (M3)'

## Module Architecture

<PREFIX>App
├── <PREFIX>World
│   ├── ApplicationClient
│   ├── FileManagerClient
│   └── UserDefaultsClient
├── <PREFIX>Model
├── <PREFIX>Design
└── Features/
    └── (<feature modules>)

## Module Naming Convention

All products and targets use the `<PREFIX>` prefix. BasicClients omit the prefix.

## Dependency Injection

Dependencies use the struct-of-closures (client) pattern. Use `/create-swift-client` to scaffold new clients.

The `World` global holds broadly-needed system abstractions. Add to `World` only if 3+ modules need the same client directly.

## State Management

Default: `@Observable` MVVM. Use an action-based reducer for features with complex, interdependent state transitions.

## Testing

Tests are mandatory for all feature work and bug fixes. Each module has a `.testTarget` in `Package.swift` and a `.xctestplan` in `TestPlans/`.

## Domain Vocabulary

<!-- Add a table of domain-specific terms and their meanings as the model develops. -->
| Term | Meaning |
|------|---------|

## Data Persistence

<!-- Describe the on-disk layout once the persistence model is decided. -->

## Key Conventions

- **One type per file** — even small helpers
- **No default parameter values** unless there is a clear, obvious reason
- **Constants must be `private`** unless part of a public interface
- **No `TODO` comments in committed code** — use GitHub issues instead
```

---

## 11. Provide next steps

After generating all files, tell the user:

1. **Connect to Xcode**: In Xcode, open (or create) your `.xcworkspace`. Add `modules/` as a local Swift package: File → Add Package Dependencies → Add Local → select the `modules/` directory.

2. **Add module imports to your app target**: In your app's `<AppName>App.swift`, import `<PREFIX>App`, create `AppRootViewModel()`, and pass it to `AppRootView`.

   ```swift
   import <PREFIX>App
   import SwiftUI

   @main
   struct <AppName>App: App {
       @State private var viewModel = AppRootViewModel()

       var body: some Scene {
           WindowGroup {
               AppRootView(viewModel: viewModel)
           }
       }
   }
   ```

3. **Create test plans**: For each module, open Xcode → Product → Test Plan → New Test Plan, name it `<PREFIX><Module>`, and save it to `TestPlans/`. Add the relevant test target to the plan.

4. **Add features**: Use `/create-swift-client` to scaffold new dependency clients. Add new feature modules by following the pattern in `Features/<Feature>/`.

5. **CLAUDE.md**: Review and update `CLAUDE.md` with any domain-specific vocabulary, data persistence layout, and module descriptions as the app grows.
