# Repository Guidelines

## Project Structure & Module Organization

This repository is an iOS app project built with Xcode. The main project file is `Dokoiku.xcodeproj`, and the app target is `Dokoiku`.

- `Dokoiku/` contains Swift source files.
- `Dokoiku/DokoikuApp.swift` defines the SwiftUI app entry point and shared SwiftData `ModelContainer`.
- `Dokoiku/ContentView.swift` contains the current primary UI.
- `Dokoiku/Item.swift` defines the SwiftData model.
- `Dokoiku/Assets.xcassets/` stores app icons, accent colors, and other asset catalog resources.

No dedicated test target is present yet. Add tests in a separate test target before introducing larger business logic.

## Build, Test, and Development Commands

Open the project in Xcode for normal development:

```sh
open Dokoiku.xcodeproj
```

List schemes and targets:

```sh
xcodebuild -list -project Dokoiku.xcodeproj
```

Build the app from the command line:

```sh
xcodebuild -project Dokoiku.xcodeproj -scheme Dokoiku -configuration Debug build
```

Run tests after a test target is added:

```sh
xcodebuild test -project Dokoiku.xcodeproj -scheme Dokoiku -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Coding Style & Naming Conventions

Follow standard Swift and SwiftUI conventions. Use 4-space indentation, `UpperCamelCase` for types, `lowerCamelCase` for properties and methods, and keep view structs focused on one screen or reusable component. Prefer `private` helpers when behavior is local to a file, as in `addItem()` and `deleteItems(offsets:)`.

Use SwiftUI previews for UI changes when practical. Keep SwiftData models small and explicit; add model properties intentionally because they affect persistence.

## Testing Guidelines

There are currently no committed tests. When adding test coverage, create an XCTest target such as `DokoikuTests`. Name test files after the type or feature under test, for example `ItemTests.swift` or `ContentViewTests.swift`. Use clear test method names like `testAddItemInsertsTimestampedItem()`.

Run the full test suite with `xcodebuild test` before opening a pull request once tests exist.

## Commit & Pull Request Guidelines

The repository currently only shows an initial commit, so no detailed commit convention is established. Use short, imperative commit messages such as `Add item deletion UI` or `Configure SwiftData container`.

Pull requests should include a concise summary, the reason for the change, test results or a note that tests are not available, and screenshots or screen recordings for visible UI changes. Link related issues when applicable.

## Security & Configuration Tips

Do not commit signing credentials, provisioning profiles, or local Xcode user state. Keep bundle identifiers, deployment targets, and signing settings intentional in `Dokoiku.xcodeproj/project.pbxproj`.

## Language rules
- Always answer in Japanese.

