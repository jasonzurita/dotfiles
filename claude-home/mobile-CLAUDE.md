# iOS / Swift Conventions

These conventions apply across all Swift/iOS projects. Project-level `CLAUDE.md` files extend or override these.

---

## SPM Module Architecture

Swift projects use a **composition tree of SPM modules**. The Xcode app target is minimal — just an `@main` entry point that creates the root view model and renders the root view. All logic lives in modules.

> **Skill available:** use `/new-swift-app` to scaffold a new project's full module architecture from scratch.

### Module Layers

```
App (root)        — orchestrates the full app, owns global dependencies
├── Features      — single-responsibility ViewModel + View pairs
├── Design        — design tokens, shared UI components
├── Model         — Codable domain types shared across features
├── World         — global dependency container (see below)
└── BasicClients  — thin struct-of-closures wrappers around system APIs
```

All modules live under `modules/Modules/` with a **single `modules/Package.swift`** declaring every target and product. The directory structure:

```
modules/
├── Package.swift          ← single SPM manifest for the entire app
└── Modules/
    ├── App/src/
    ├── Features/
    │   └── <FeatureName>/src/
    ├── Model/src/
    ├── Design/src/
    ├── World/src/
    └── BasicClients/
        ├── ApplicationClient/src/
        ├── FileManagerClient/src/
        └── UserDefaultsClient/src/
```

### Module Naming

Use a short project-specific prefix for all products (e.g., `SH` for Set Hike): `SHApp`, `SHModel`, `SHDesign`, `SHWorld`, `SHFormationsFeature`. BasicClients omit the prefix — they are generic wrappers that may be reused across projects.

### The World Pattern

`World` holds dependencies that are broadly needed across many modules — things like the current date, file system access, and core system abstractions.

```swift
public let Current: World = .live()

public struct World: Sendable {
    public var currentDate: @Sendable () -> Date
    public var fileManagerClient: FileManagerClient
    public var userDefaultsClient: UserDefaultsClient
}
```

**Goes in World:** date/time provider, FileManager, UserDefaults, ApplicationClient — anything 3+ modules need directly.
**Does not go in World:** feature-specific clients, clients used by only 1–2 modules.
When in doubt, inject directly rather than adding to `World`.

### Module Creation Guidelines

**Create a new SPM module by default.** Modules are cheap and enforce separation of concerns at the compiler level.

> If it represents a single idea or a potentially reusable unit with isolated tests, it gets its own module.

- New feature → new module under `modules/Modules/Features/` (or top-level for major features)
- New system dependency wrapper → new module under `modules/Modules/BasicClients/`
- New domain concept → extend `Model` or create a focused sub-model module

Only skip a new module if the addition is trivially small and tightly coupled to an existing module with no reuse potential. **When unclear, ask before deciding.**

**Every new module gets:**
1. A target + product entry in `Package.swift`
2. A `.testTarget` in `Package.swift`
3. A corresponding `.xctestplan` in `TestPlans/` (created via Xcode's test plan editor)

---

## Dependency Injection — The Client Pattern

> **Skill available:** use `/create-swift-client` to scaffold a new client (Interface, Live, Mocks) interactively.

Dependencies are modeled as **structs of closures**, not protocols. Each client has three files:

- `Interface.swift` — the struct definition with closure properties
- `Live.swift` — the real implementation (`static func live() -> Self`)
- `Mocks.swift` — test doubles (`static func mock(...)` and `.happyPath()`)

```swift
// Interface.swift
public struct MyClient: Sendable {
    public var doThing: @Sendable (Input) async throws -> Output

    public init(doThing: @escaping @Sendable (Input) async throws -> Output) {
        self.doThing = doThing
    }
}

// Live.swift
public extension MyClient {
    static func live() -> Self {
        .init(doThing: { input in /* real implementation */ })
    }
}

// Mocks.swift
public extension MyClient {
    static func mock(
        doThing: @escaping @Sendable (Input) async throws -> Output = { _ in .placeholder }
    ) -> Self {
        .init(doThing: doThing)
    }

    static func happyPath() -> Self { .mock() }
}
```

Rules:
- Use `@MainActor` on closures that must run on the main thread; `@Sendable` on all others
- Explicit `public init(...)` always — no memberwise init, no default values in the struct definition
- Clients are injected via initializer parameters, never accessed globally
- A dependency container (`World`, `Environment`, etc.) is only warranted when 3+ modules need the same client

---

## State Management

Architecture is chosen per feature. There is no single mandated pattern.

### Default: MVVM with `@Observable`

```swift
@Observable
final class MyFeatureViewModel {
    var someState: String = ""
    private let myClient: MyClient

    init(myClient: MyClient) {
        self.myClient = myClient
    }
}
```

### Unidirectional / Reducer — when to use it

Use `send(_ action:)` with an exhaustive action enum when:
- State transitions have many interdependencies
- An action audit log is valuable
- Exhaustive, compile-time-checked action handling matters
- Every state transition needs to be testable in isolation

When in doubt, start with `@Observable` MVVM and migrate if complexity demands it.

---

## SwiftUI Architecture

### Dumb UI Rule

SwiftUI views are pure functions of state. They:
- Receive data via `@Binding`, `@Environment`, or observed view models
- Emit user actions (taps, inputs) upward via closures or actions
- Contain **zero** business logic, zero direct service calls, zero persistence calls

If a view needs to decide something, that decision belongs in a use case or service, not the view.

### Services

- All mutable shared state lives in `@Observable` service objects.
- Services own use case instances and call them in response to user actions.
- Services **never** import SwiftUI.

---

## Testing

**Tests are mandatory for all feature work and bug fixes.**

- No implementation code is written before a corresponding test exists.
- **Regression guard**: any bug must first be reproduced by a failing test before it is fixed.
- **Broken test protocol**: when a change causes an existing test to fail, investigate first — do not update the test to make it pass without confirming the new behavior is intentionally correct. A silently updated test masks regressions.

### Conventions

- Use `.mock(...)` or `.happyPath()` for injected dependencies — never hit real file system, network, or system APIs in unit tests
- Use fixed, deterministic values for dates (`Date(timeIntervalSince1970: ...)`) and IDs
- Build small helper functions/fixtures to construct test state rather than repeating setup inline

### What to test

- State transitions (especially in reducer-style features)
- ViewModel logic (actions, computed properties, side-effect triggers)
- Client implementations via integration tests where appropriate
- Edge cases and regression cases explicitly

### Previews

Every SwiftUI view must be renderable in isolation with mock data. If a view cannot be previewed without a real API call or real device state, it is an architecture violation — fix the dependency injection first.

- Every view file includes a `#Preview` block using Mock client implementations.
- Previews must cover: the happy path, an empty/zero-state, and at least one error state.
- No preview should require a real network call or a real device sensor.

---

## Key Swift Principles

- **One type per file**: every type (struct, class, enum, protocol) gets its own file, even small helpers. Types buried inside other files are hard to find.
- **Constants must be `private`**: any `let` not part of a public interface must be `private`. Private by default keeps interfaces minimal.
- **No default parameter values** unless there is a clear, obvious reason. Default values hide intent and let callers be lazy — explicit call sites make code easier to read and harder to misuse.
- **Single source of truth**: state lives in one place; views and derived values flow from it.
- **Single responsibility**: ViewModels coordinate; clients execute; models represent.
- **Prefer value types**: use structs over classes where practical; keep modules loosely coupled.

---

## Code Style

- **Logging**: use `os.Logger` (unified logging). Never `print()`. Each module defines its own `Logger` instance with its subsystem so output can be filtered in Console.app.
- **No `TODO` comments in committed code.** If something is deferred, it gets a GitHub issue, not a comment.
