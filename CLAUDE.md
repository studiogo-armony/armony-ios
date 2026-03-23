# Armony iOS — AI assistant context

This file is a **short orientation** for tools like Claude and Cursor. For screenshots, full code samples, and step-by-step setup, use **[README.md](README.md)**.

## What this is

**Armony** is an iOS app that helps musicians connect: profiles, skills, discovery, chat, and related flows. It is open source; product info lives at [armony.app](https://armony.app).

## Tech stack

- **Language:** Swift  
- **UI:** UIKit and SwiftUI (mixed; new screens often SwiftUI, embedded in UIKit navigation)  
- **Minimum iOS:** 15.0 (some SwiftUI features expect iOS 16+ per README)  
- **Architecture:** MVVM-C (Model–View–ViewModel + **Coordinators**)  
- **Dependencies:** Swift Package Manager (via Xcode). Notable libraries include Alamofire, AlamofireImage, and [UIScrollView-InfiniteScroll](https://github.com/pronebird/UIScrollView-InfiniteScroll).  
- **Style:** Align with the [Ray Wenderlich Swift style guide](https://github.com/raywenderlich/swift-style-guide) (see README).

## Opening the project

- Open the Xcode project: **`Armony/Armony.xcodeproj`** (not a standalone `Package.swift` at repo root).  
- Shared schemes include **`Armony.xcscheme`** and **`Armony-Debug.xcscheme`** under `Armony/Armony.xcodeproj/xcshareddata/xcschemes/`.

## Repository layout (high level)

- **`Armony/Armony.xcodeproj`** — Xcode project; open this to build.  
- **`Armony/Armony/`** — Main app target source. Notable groups include:  
  - **`Common/`** — Shared UI, analytics, deeplink helpers, validation, protocols, reusable components.  
  - **`Scenes/`** — Feature modules: typically `API` (tasks/models), presentation/views, coordinators, storyboards/XIBs as used by the feature.  
  - **`API/`** — REST stack (e.g. `RestService`, `RestAPI`, response types).  
  - **`Services/`** — Integrations such as Firebase; other top-level folders include socket and remote-notification related code as present in the tree.

Feature folders follow patterns described in README (e.g. coordinator + view model + view controller + storyboard where applicable).

## Patterns to respect

### Coordinators and SwiftUI

Navigation uses **coordinators** for both UIKit and SwiftUI. SwiftUI screens are often shown via **`UIHostingController`** and the same navigation stack as UIKit. Changing coordinator flow affects deep links and back stack—keep behavior consistent with existing features.

### Networking

Networking is layered around **`RestService`**, **`HTTPTask`**, and typed responses such as **`RestObjectResponse`** / **`RestArrayResponse`**. New API work should mirror existing **`HTTPTask`** structs and `execute(task:type:)` usage rather than inventing a parallel stack.

### Deep linking

**`URLNavigator`** and **`URLNavigatable`** register routes and tie them to coordinators. Edits here affect authentication gating and URL-driven navigation; see README for registration examples.

## Reference features: Settings and Filter (MVVM-C)

These two flows illustrate how MVVM-C is applied consistently:

### Settings (`Armony/Armony/Scenes/Settings/`)

- **`SettingsCoordinator`** — Implements **`Coordinator`**: `start()` creates the view controller and **`SettingsViewModel`**, assigns **`viewModel.coordinator`**, then **`push`**es onto the existing navigator. Also conforms to **`URLNavigatable`** so the screen can be opened via the app’s URL/deeplink system.
- **`SettingsViewModel`** — Subclasses **`ViewModel`** (inherits **`RestService`**). Loads menu data with **`GetSettingsTask`** and maps responses to **`SettingsPresentation`** / **`SettingPresentation`** (cell-ready models). Row selection calls **`coordinator.open(deeplink:)`**, so **sub-features are not pushed directly from the view model**; navigation goes through **`URLNavigator`** using each row’s **`Deeplink`**.
- **`SettingsViewController`** — Storyboard-based UI; conforms to **`SettingsViewDelegate`** for reload/activity patterns; table data source reads from the view model.

### Filter (`Armony/Armony/Scenes/Filter/`)

- **`FilterCoordinator`** — Presents a **new** `UINavigationController` whose root is **`FilterViewController`** (modal flow). Accepts optional **`FilterViewModelDelegate`** and initial **`Filters`** for the parent to receive results.
- **`FilterViewModel`** — Handles async **`RestService`** calls (e.g. **`GetAdvertTypesTask`**, **`GetLocationTask`**), updates state, and drives UI through **`FilterViewDelegate`**. Sub-flows (e.g. bottom selection) use **nested coordinators** such as **`SelectionBottomPopUpCoordinator`** with **`coordinator.navigator`**. **Apply** dismisses via the coordinator and notifies the **delegate** with the selected filters.

### Takeaways for new work

- **Coordinator**: Owns **how** the screen appears (push vs present) and **wires** `viewModel.coordinator`. Prefer **`open(deeplink:)`** for cross-feature moves when the menu or flow is already modeled with deeplinks (as in Settings).
- **View model**: State + **`RestService`**; **weak** view-protocol for UI callbacks; avoid pushing view controllers from the VM—use **coordinator** or **deeplinks**.
- **View controller**: Thin: gestures/actions call the view model; rendering implements the view protocol.

When adding a feature, find the closest match (hub screen like **Settings** vs modal flow like **Filter**) and mirror its coordinator and view-model boundaries.

## Secrets and configuration

- **Do not** commit real API keys, tokens, or full **`GoogleService-Info.plist`** / **`GoogleService-Info-Debug.plist`** contents.  
- Local configuration is described in README under **Secrets**; values are typically supplied via **xcconfig** files such as:  
  - `Armony/Resources/Configs/DebugConfiguration.xcconfig`  
  - `Armony/Resources/Configs/ReleaseConfiguration.xcconfig`  

Treat any file that holds secrets as **local-only** unless the project explicitly documents otherwise.

## CI and automation

- **GitHub Actions:** [`.github/workflows/`](.github/workflows/) — e.g. `create_release_branch.yaml`, `merge_release_to_main.yaml`, `merge_main_to_development.yaml` (release branching and branch sync).  
- **Xcode Cloud–style scripts:** [`Armony/ci_scripts/`](Armony/ci_scripts/) — `ci_pre_xcodebuild.sh`, `ci_post_clone.sh`, `ci_post_xcodebuild.sh` (validate env, configure plists, post-build steps as documented in README).

## Working agreement for AI changes

- Prefer **small, focused diffs** that match existing naming, folder structure, and patterns in the touched feature.  
- When adding screens or APIs, **find a similar feature** in `Armony/Armony/Scenes/` and follow it.  
- **Run builds/tests in Xcode** (or CI) before merging; this repo is not fully verifiable from text alone.  
- If behavior spans navigation, networking, or URLs, **cross-check README** sections on coordinators, deep linking, and networking.

## When in doubt

Read **[README.md](README.md)** for prerequisites, installation, screenshots, extended examples (coordinators, deep links, `RestService`), and CI script details.
