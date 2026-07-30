# PayrollApp

SwiftUI payroll app for the WeSure iOS interview exercise. You can create payrolls, add employees, and review wages and taxes. There’s no real backend — data goes through a network abstraction with a mock API, and the app works offline via local storage.

---

## How to run the project

1. Clone this repo and open `PayrollApp.xcodeproj` in **Xcode 15+** (iOS 17 deployment target).
2. Select an iPhone simulator or a physical device.
3. Press **Run** (`⌘R`).

On first launch you’ll see the sample payroll from the brief (Sarah / James / Laura) so you can check the tax math right away.

### Running tests

In Xcode: **Product → Test** (`⌘U`), or from this folder:

```bash
xcodebuild test \
  -scheme PayrollApp \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

---

## Architectural decisions

I used **MVVM** with SwiftUI:

```
Views
  └── ViewModels (@Observable, @MainActor)
        └── PayrollRepository (actor)
              ├── PayrollAPIClient → MockPayrollAPIClient
              └── PayrollStore     → FilePayrollStore (JSON on disk)
```

**Why this shape:**

- **Views stay simple.** Screens handle layout and navigation; view models own loading, saving, and form state.
- **Repository as the data gateway.** All reads/writes go through `PayrollRepository`. It tries the “network” first, falls back to local JSON when that fails, and keeps offline-created payrolls when remote data comes back.
- **Network behind a protocol.** `PayrollAPIClient` is the abstraction the brief asked for. Today it’s `MockPayrollAPIClient` (with a short delay). A real `URLSession` client can replace it later without touching the UI.
- **Shared tax rules.** `TaxCalculator` owns the rule (wages > $1,000 and not exempt → 5%). Models use it so list, detail, and create stay consistent.
- **Actors for concurrency.** The mock API and repository are actors so concurrent access stays safe; view models stay on the main actor for UI updates.

---

## Anything I would improve given more time

If I had longer on this, I’d focus on:

1. **Offline sync** — a proper queue to retry creates when the network returns, instead of only merging local + remote.
2. **Edit / delete** — payrolls and employees aren’t editable after create right now.
3. **Form UX** — inline validation, a proper currency field, and clearer empty states.
4. **Persistence** — move from JSON files to Core Data or SwiftData for safer writes at scale.
5. **Testing** — UI tests for list → create → detail, and more view-model coverage.
6. **Accessibility** — VoiceOver and Dynamic Type polish.
7. **Product extras** — search/filter on the list, and configurable tax rules instead of hard-coded values.

Happy to discuss any of these choices in more detail.
