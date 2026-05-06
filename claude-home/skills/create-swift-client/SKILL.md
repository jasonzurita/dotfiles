---
name: create-swift-client
description: Scaffolds a new dependency client using the struct-of-closures pattern — creates Interface.swift, Live.swift, and Mocks.swift, then registers the target where appropriate.
allowed-tools: Read, Edit, Write, Bash
---

Create a new Swift dependency client using the steps below.

## 1. Gather information

Ask the user (if not already clear from context):
- **Client name** — e.g. `NotificationClient`
- **Operations** — what does this client do? List each as: name, inputs, output, whether it throws, whether it's async
- **Threading** — for each operation: does it need `@MainActor` (touches UIKit/main thread), or is `@Sendable` sufficient?
- **Location** — where should the files live? Check the project's `CLAUDE.md` for conventions. If unclear, ask.
- **Package registration** — does this project use SPM? If so, what is the `Package.swift` path and what dependencies does this client need?

Do not proceed until you have the client name and at least one operation.

## 2. Create Interface.swift

Rules:
- The struct is `public` and conforms to `Sendable`
- Each operation is a `public var` closure property
- Use `@MainActor` on closures that must run on the main thread; use `@Sendable` on all others
- Include an explicit `public init(...)` that assigns every property — no memberwise init, no default values in the struct definition
- One type per file — if a supporting type is needed, give it its own file

```swift
import Foundation

public struct <ClientName>: Sendable {
    public var <operation>: @Sendable (<Inputs>) -> <Output>

    public init(
        <operation>: @escaping @Sendable (<Inputs>) -> <Output>
    ) {
        self.<operation> = <operation>
    }
}
```

## 3. Create Live.swift

Rules:
- Written as a `public extension <ClientName>`
- Single static factory `static func live() -> Self`
- Calls real system APIs or delegates to another injected dependency
- No business logic — just wiring

```swift
import Foundation

public extension <ClientName> {
    static func live() -> Self {
        .init(
            <operation>: { /* real implementation */ }
        )
    }
}
```

## 4. Create Mocks.swift

Rules:
- Written as a `public extension <ClientName>`
- `static func mock(...)` — every parameter is a closure with a sensible no-op or safe default
  - Void returns: `= { _ in }`
  - Value returns: `= { _ in <placeholder> }`
- `static func happyPath() -> Self` — calls `.mock()` with defaults representing normal, successful execution. If identical to all defaults, this is just `return .mock()`.
- Add additional named variants (e.g. `.failing()`, `.noop`) only if there is a clear, immediate need

```swift
import Foundation

public extension <ClientName> {
    static func mock(
        <operation>: @escaping @Sendable (<Inputs>) -> <Output> = { _ in <default> }
    ) -> Self {
        .init(<operation>: <operation>)
    }

    static func happyPath() -> Self {
        .mock()
    }
}
```

## 5. Register in Package.swift (if applicable)

If the project uses SPM, add a `.target` and `.library` entry. Follow the naming conventions in the existing `Package.swift` exactly.

```swift
// products:
.library(name: "<ClientName>", targets: ["<ClientName>"]),

// targets:
.target(
    name: "<ClientName>",
    dependencies: [],
    path: "<path-to-src>"
),
```

If the client has tests, also add a `.testTarget`. If not, note that a test target should be added before shipping.

## 6. Remind the user of next steps

- Add the client as a dependency to any module that needs it
- Inject via initializer — not globally
- Run the relevant tests to confirm the build is clean
