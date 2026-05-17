# Contributor Guidelines

Thank you for contributing to Mercury 🚀
- Alessandro
- Marco

Mercury is a SwiftUI-based Telegram client for Apple Watch built on top of TDLibKit.  

This document defines the architectural patterns, code style, and pull request rules that contributors must follow.

Before contributing, please read this guide carefully.

## Project Structure

```text
Mercury Watch App/
├── Pages/
│   └── <Feature>/
│       ├── <Feature>Page.swift
│       ├── <Feature>ViewModel.swift
│       ├── <Feature>ViewModel+Area.swift
│       ├── Subviews/
│       │   └── <Component>View.swift
│       └── Subpages/
│           ├── <Flow>Subpage.swift
│           └── <Flow>ViewModel.swift
├── Shared/
│   ├── Components/
│   │   └── <ReusableComponent>View.swift
│   └── Models/
│       └── <SharedModel>.swift
├── Utils/
│   ├── Services/
│   │   └── <Feature>Service.swift
│   └── Extensions/
│       └── Type+.swift
├── TDLib/
│   ├── TDLibManager.swift
│   ├── TDLibManagerProtocols.swift
│   └── TDLibViewModel.swift
├── Assets.xcassets/
└── Old/
```

- `Mercury Watch App/Pages/<Feature>/` contains the main screens. Use the `Page` suffix for the root view of a screen and `ViewModel` for the related logic.
- `Pages/<Feature>/Subviews/` contains feature-specific components. Do not move reusable components used elsewhere in the app here.
- `Pages/<Feature>/Subpages/` contains screens presented by a feature, such as sheets or secondary flows.
- `Shared/Components/` contains reusable views and modifiers that are independent from a specific feature.
- `Shared/Models/` contains models shared across multiple features.
- `Utils/Services/` contains wrappers for operational functionality, such as audio, logging, file system access, and message sending.
- `Utils/Extensions/` contains extensions for Foundation, SwiftUI, or TDLibKit types. Files must follow the `Type+.swift` pattern.
- `TDLib/` contains the TDLib manager, protocols, and the shared base view model.
- `Assets.xcassets/` and its dedicated subfolders are the right place for colors, icons, and images. Keep names descriptive and consistent with the existing assets.
- `Old/` contains legacy code. Do not add new functionality there.
- Keep one component per file. A file may include the component's small local model, mock data, and previews, but it should not define multiple independent components.

## Naming

- Use `PascalCase` for types, enums, and structs: `ChatListPage`, `SendMessageService`, `MessageModel`.
- Use `camelCase` for properties, methods, and variables: `isLoading`, `chatAction`, `requestMessages`.
- Root feature views must end with `Page`: `LoginPage`, `HomePage`, `SettingsPage`.
- Flows presented by a feature must end with `Subpage`: `VoiceNoteRecordSubpage`, `MessageOptionsSubpage`.
- Visual components must end with `View`: `AvatarView`, `ReactionView`, `ChatCellView`.
- UI-facing models must end with `Model`: `ChatCellModel`, `AvatarModel`, `MessageModel`.
- Services must end with `Service`: `LoggerService`, `PlayerService`, `RecorderService`.
- Mock classes use the `Mock` suffix and live close to the real type: `ChatListViewModelMock`, `SendMessageServiceMock`.
- Files that extend a class for a specific responsibility use `Type+Area.swift`, for example `ChatDetailViewModel+Messages.swift` and `ChatListViewModel+Updates.swift`.

## SwiftUI and Architecture

- Keep the `Page` + `ViewModel` pattern for features. The view defines the layout and delegates actions and side effects to the view model.
- Business logic, navigation decisions, side effects, data loading, and user interaction handling must stay in the `ViewModel`. `Views` should remain focused on rendering and binding UI events to view model methods.
- UI state must be defined in view models, not inside views, unless the state is purely local and visual, such as a temporary animation or focus value.
- Page view models must extend `TDLibViewModel`. Subpage view models must not depend on TDLibKit directly.
- Use `@Observable` on view models that need to update the UI, in line with the existing code.
- View models in views must be defined as `@Mockable`, using `@State @Mockable var vm`. For initializers with parameters, use `Mockable.state(value:mock:)`.
- Keep UI models lightweight and local to the view when they are only used by that view. Move them to `Shared/Models` only when they are shared across features.
- When a view grows, extract subviews with `@ViewBuilder` functions or files in `Subviews/`, following the existing style.
- When a view model becomes too large, split its responsibilities into extension files using the `ViewModel+Area.swift` pattern, for example `ChatDetailViewModel+Interactions.swift`, `ChatDetailViewModel+Messages.swift`, or `ChatListViewModel+Updates.swift`.
- Use `#Preview(traits: .mock())` to use mocks in previews.

## TDLib and Async

- `TDLibKit` may be imported only in page view models and in the dedicated TDLib layer. Do not import `TDLibKit` in `Page`, `Subview`, or `Subpage` UI files.
- All TDLib calls must go through `TDLibManager.shared.client`.
- Encapsulate repeated operational calls in a service instead of duplicating them in views.
- Use `Task.detached` or `Task` for asynchronous work and send UI updates back through `MainActor.run`.
- TDLib updates must be routed in `updateHandler(update:)` with a `switch` on the update type.
- If a class subscribes to TDLib updates, make it inherit from `TDLibViewModel` so subscription, unsubscribe, and logging stay centralized. This applies to page view models only.
- Log relevant errors and results with `LoggerService`, using `.error` for handled failures.
- Do not access secrets or credentials directly outside `SecretService`.

## Mocks, Demo, and Previews

- Every page view model must have a mock equivalent with representative sample data.
- Mocks must override methods that interact with real data, such as TDLib calls, audio recording, or message sending.
- Keep mock data small but representative: include loading states, empty content, long content, and image/audio cases when relevant.
- Do not use real credentials, personal IDs, or sensitive data in mocks.
- Every visual component must have previews for each meaningful state it supports, such as loading, empty, populated, error, selected, disabled, incoming/outgoing, or permission-restricted states.

## Swift Code Style

- Use 4 spaces for indentation.
- Maintain compatibility with Swift 5 and watchOS 10.1, as configured in the project.

## UI and watchOS

- Design for Apple Watch: compact layouts, short text, large controls, and readable states.
- Use native SwiftUI components and SF Symbols for toolbars, buttons, and navigation actions.
- Respect the existing style: `NavigationStack`, `List` with `.carousel`, top or bottom toolbar items, and sheets for secondary flows.
- Use colors from the asset catalog or SwiftUI colors already used in the project. Add colors to `Assets.xcassets` only when they are part of a recurring design.
- Avoid heavy UIs or long informational screens. Screens must be actionable and easy to scan on the wrist, while avoiding tap targets that are too small.
- When showing remote or expensive content, use patterns similar to `AsyncView` with a placeholder.

## Files and Assets

- Add new files to the feature folder closest to their responsibility. If a component becomes shared, move it to `Shared/Components`.
- For TDLib extensions or mappings from TDLib to UI models, prefer `Utils/Extensions` or dedicated `ViewModel+...` files.
- Keep asset names in English, descriptive, and lowercase when possible.
- Do not commit temporary generated files, local recordings, TDLib databases, or credentials.

## Error Handling and Logging

- Do not silently ignore TDLib errors. Log with `self.logger.log(error, level: .error)` when the error is useful for diagnosis.
- Every `do`/`catch` used around asynchronous work, TDLib calls, file system access, audio, or services must save the caught error to `LoggerService`.
- For non-critical operations, use fallback UI or return empty arrays/models, as the existing loaders do.
- Avoid intentional crashes or force unwraps in new code, especially around TDLib, file system access, and audio.

## Thank You

Thank you for helping improve Mercury ❤️
