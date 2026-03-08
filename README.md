# Places

Places is a SwiftUI app that fetches a list of locations from a remote source and lets the user open any of them or a manually entered coordinate in the Wikipedia app.

The architecture is MVVM throughout. Each screen has its own View and ViewModel, the network layer lives in a dedicated service, and shared utilities are kept in helpers. The goal was to write code that feels natural in SwiftUI while applying modern Swift concurrency correctly.

---

## Homepage

The Homepage is the first screen the user sees. It fetches places on launch, shows a loading indicator while waiting, renders the list when data arrives, and falls back to an error view with a retry button if something goes wrong.

### HomepageViewModel

`HomepageViewModel` is marked `@MainActor`. This means every property access and state update runs on the main thread, which is exactly where SwiftUI expects UI driving state to live. Because the class itself is isolated to the main actor, there is no need to hop back to the main thread manually after an `await`, Swift handles that automatically.

The `state` property is an enum (`loading`, `success`, `failure`) that drives the entire UI. It starts as `loading`, gets updated to `success` once data arrives, or to `failure` with an error message if the network call throws. This pattern avoids holding separate booleans like `isLoading` or `hasError` alongside optional data, which quickly becomes fragile.

`fetchPlaces` calls `LocationService.fetchLocations()` using `async/await`. Since `URLSession.data(from:)` suspends at the `await` point and does its I/O work off the main thread, the main thread is never blocked, even though the ViewModel is `@MainActor`. The function only resumes on the main actor once the data is ready.

`LocationService` is injected through a protocol (`LocationServiceProtocol`), which makes the ViewModel testable without hitting the network.

### HomepageView

The view observes the ViewModel via `@StateObject` and switches over its `state` to render the appropriate UI. No separate boolean flags, no optional unwrapping in the view body, just a clean switch.

Data loading is triggered with `.task { ... }` instead of `.onAppear`. The key difference is that `.task` is tied to the view's lifecycle and is automatically cancelled when the view disappears, which is the right behavior for async work. More importantly, the fetch only runs when `state == .loading`. If the user navigates away and comes back, state is already `.success` and no redundant network call is made.

When the user taps a location row, `openInWikipedia(location:)` is called on the ViewModel. The ViewModel builds the deep-link URL and fires off a `Task` internally, the View does not need to know anything about the async nature of that operation.

---

## Custom Location

The Custom Location screen is presented as a sheet. It gives the user two text fields to enter a latitude and longitude, validates the input in real time, and opens Wikipedia once the user taps the button.

### CustomLocationViewModel

The ViewModel holds `latitudeText` and `longitudeText` as `@Published` strings. Using strings here is intentional, a `TextField` needs a `String` binding, and coordinate input can be partial or invalid at any moment during typing (e.g. `"52."` or `"-"`). Storing that as `Double?` would fight against the natural editing flow.

The `isValid` computed property parses both strings to `Double` and checks that they fall within valid geographic ranges. Since it is computed from `@Published` properties, SwiftUI re-evaluates it on every keystroke and keeps the button's disabled state in sync without any extra code.

`openInWikipedia()` parses the input one more time, builds the URL, and calls `WikipediaRedirectionHelper`. If the Wikipedia app fails to open, `errorMessage` is set, which triggers an alert on the view side.

The ViewModel is also `@MainActor`, keeping all state mutations consistent on the main thread.

### CustomLocationView

The view binds its text fields directly to `$viewModel.latitudeText` and `$viewModel.longitudeText`. SwiftUI's binding takes care of propagating keystrokes back to the ViewModel, no manual `onChange` or delegate pattern needed.

The "Open in Wikipedia" button is disabled while `isValid` is false and dismisses the sheet on success. If `errorMessage` is non-nil after the call, an alert is shown before dismissal.

---

## WikipediaRedirectionHelper

This is a stateless `struct` with a single `static` function. It takes a latitude and longitude, builds the URL in the format `wikipedia://places/?latitude={lat}&longitude={long}`, and calls `UIApplication.shared.open(...)`, which returns a `Bool` indicating whether the app was opened successfully.

`UIApplication.shared.open` is an async function under the hood, so the helper is correctly marked `async`. The `wikipedia` URL scheme is also declared in `LSApplicationQueriesSchemes` in Info.plist — without that entry, iOS would block the query entirely and `open` would always return `false`.

---

## Model

`Location` is a simple `Decodable` struct with optional `name`, `lat`, and `long` fields, optional because the API does not guarantee all fields are present for every entry.

The `displayName` computed property handles the fallback logic: name if available, formatted coordinates if not, and "Unknown Location" as a last resort. This keeps the display logic in one place rather than scattered across views.

`Location` conforms to `Identifiable` using a `UUID` generated at init time, which is required for `ForEach` in SwiftUI.

---

## Accessibility

Accessibility identifiers were added to the main interactive elements across both screens; the location list, each row, the retry and add location buttons, text fields, and action buttons. `accessibilityLabel` was set where the default label would be ambiguous (e.g. the `+` button in the toolbar). This serves two purposes: VoiceOver users get a clearer experience, and UI tests have stable, human-readable handles for finding elements without relying on text content that might change.

---

## Tests

`HomepageViewModelTests` covers the two meaningful behaviors of `fetchPlaces` — the state transitioning to `.success` with the expected data, and to `.failure` with the right error message. `LocationService` is mocked through the `LocationServiceProtocol` so tests are fully deterministic and offline.

`CustomLocationViewModelTests` covers the `isValid` validation logic — the cases where coordinates are within range and where they are out of range. This is pure logic with no side effects, which makes it a natural fit for unit testing.
