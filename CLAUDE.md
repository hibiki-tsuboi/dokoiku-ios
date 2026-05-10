# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

Open in Xcode for normal development:
```sh
open Dokoiku.xcodeproj
```

Build from the command line:
```sh
xcodebuild -project Dokoiku.xcodeproj -scheme Dokoiku -configuration Debug build
```

List schemes and targets:
```sh
xcodebuild -list -project Dokoiku.xcodeproj
```

Run tests (once a test target exists):
```sh
xcodebuild test -project Dokoiku.xcodeproj -scheme Dokoiku -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Architecture

SwiftUI + SwiftData iOS app. No third-party dependencies.

- `DokoikuApp.swift` — app entry point; creates the shared `ModelContainer` with `Item` schema and injects it via `.modelContainer()`.
- `ContentView.swift` — primary UI using `NavigationSplitView`. Reads items via `@Query`, inserts/deletes via `modelContext`.
- `Item.swift` — single `@Model` class with a `timestamp: Date` property. Adding properties here affects the persistent store schema.

There is no test target yet. When adding one, name it `DokoikuTests` and mirror source file names (e.g. `ItemTests.swift`).

## Coding conventions

- 4-space indentation, `UpperCamelCase` types, `lowerCamelCase` properties/methods.
- Keep view structs scoped to one screen or reusable component; use `private` helpers for file-local behavior.
- Use SwiftUI previews for UI changes. For previews that need SwiftData, use `.modelContainer(for: Item.self, inMemory: true)`.
- Add SwiftData model properties intentionally — they affect the persistence schema.

## Commit style

Short imperative messages: `Add item deletion UI`, `Configure SwiftData container`. PRs should include screenshots or recordings for visible UI changes.

## Language rules
- Always answer in Japanese.

