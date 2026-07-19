# CLAUDE.md

Guidance for Claude Code when working in this repository.

## Project overview

DatePlus is a watchOS date-calculator app: pick a number of days and see the
resulting date, on the watch and as watch-face complications / Smart Stack
widgets.

- `DatePlusWatchApp/` — the watchOS app (SwiftUI). Entry point and shared state
  in `App/`, screens in `Features/`, watchOS 9/10 navigation split in
  `Navigation/`.
- `DatePlusWidgetExtension/` — the WidgetKit extension providing three
  complication slots for the accessory families.
- `DatePlusContainer/` — iOS container app metadata only.
- `Packages/DatePlusCore/` — local Swift Package with all domain, persistence,
  and localization logic. Prefer putting testable logic here.
- `Configurations/` — shared xcconfig build settings.
- `ci_scripts/` — Xcode Cloud lifecycle scripts (required location; TestFlight
  build numbers are assigned by Xcode Cloud, not by `CURRENT_PROJECT_VERSION`).

## Build & test

```sh
# Unit tests (fast; run these first)
swift test --package-path Packages/DatePlusCore

# App and extension builds
xcodebuild -project DatePlus.xcodeproj -scheme 'DatePlus Watch App' \
  -configuration Debug -destination 'generic/platform=watchOS Simulator' build
xcodebuild -project DatePlus.xcodeproj -scheme 'DatePlus WidgetExtension' \
  -configuration Debug -destination 'generic/platform=watchOS Simulator' build
```

Simulator installs need code signing (the default); `CODE_SIGNING_ALLOWED=NO`
strips the App Group entitlement and breaks shared-data verification.

## Hard constraints (compatibility contracts)

Understand these before touching persistence or the widget extension. They are
contracts with released builds and with WidgetKit state on users' watches:

- **Widget kinds `[1]`, `[2]`, `[3]` must never change.** WidgetKit persists
  the kind inside every configured watch-face complication; renaming a kind
  permanently orphans all existing configurations.
- **App Group and storage keys are frozen**: `group.net.root-lump.date-plus`,
  and the UserDefaults keys in `StorageConfiguration` (notably `dayInfos`, a
  positional three-item JSON array). Changing them requires an explicit
  migration plan.
- **The widget descriptor path must stay static and storage-free.**
  `configurationDisplayName` / `.description` accept only explicitly typed
  `String` values; the formatted `Text` / `LocalizedStringKey` overloads trap
  at descriptor-query time and take down every complication. No App Group I/O
  while building descriptors, and `placeholder(in:)` must be deterministic.
- **watchOS 9 deployment target.** Keep the `#available(watchOS 10, *)` /
  `#available(watchOSApplicationExtension 10, *)` branches intact.
- **Widget extension assets stay small.** The extension runs under a tight
  memory ceiling (especially on arm64_32 watches); images are pre-sized to
  their rendered dimensions. Do not add large assets to the extension.

## Branching & flow

Features branch off `develop` and merge back via PR. Releases flow
`develop` → `release` → `main` (`main` mirrors the App Store version).

- Branch names, commit messages, and PR conventions are defined by the
  repository skills in `.claude/skills/` (`branch-naming`,
  `create-pull-request`). Follow them for every branch and PR.
- Commit messages use lowercase conventional prefixes as seen in history:
  `feat:`, `fix:`, `refactor:`, `chore:`, `docs:`, `test:`, `perf:`, `ci:`,
  `style:`, `build:`, `release:`.

## Language policy

- Everything written **into the repository** — code, comments, commit
  messages, branch names, PR titles and bodies, issues, and documentation —
  is written in **English**.
- Conversation output **to the user in the shell** (explanations, questions,
  reports) follows **the user's language**.
