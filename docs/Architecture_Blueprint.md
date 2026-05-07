# CanvasBridge iOS Architecture Blueprint

## 1. System Overview
CanvasBridge employs a hybrid **MVVM-C** (Model-View-ViewModel-Coordinator) architectural pattern to manage the application's lifecycle and presentation logic.
- **Navigation (UIKit)**: The Coordinator layer (referred to as Flows) leverages native `UINavigationController` to manage app routing and screen transitions, maintaining a clean separation of concerns.
- **Views (SwiftUI)**: The UI layer is implemented in `SwiftUI`. SwiftUI views (like `MainViewUI`) are wrapped in a generic `BaseHostingController<T: View>`, which acts as the UIKit-compatible container (`MainViewController`) controlled by the Flow.
- **Testing**: The project uses Apple's native **Swift Testing** framework (`import Testing`) for unit testing.

## 2. Dependency Graph
Dependency injection is managed centrally using **Swinject**.
- **Container Setup**: The `DIContainer.swift` file initializes a static, globally accessible container grouped by `Assembly` components.
- **Assemblies**: 
  - `FlowAssembly`: Registers factory closures for Coordinators (`AppFlow`, `MainFlow`).
  - `ModuleAssembly`: Registers the MVVM modules (e.g., configuring `MainView` by instantiating `MainViewModel`, `MainViewUI`, and `MainViewController`, then binding their inputs/outputs).
  - `ServiceAssembly`: Reserved for shared services and data providers.
- **Injection Flow**: When a Flow needs to navigate, it relies on Factory protocols (e.g., `ModuleFactory`, `FlowFactory`). It invokes a `make...()` function which queries the Swinject `Resolver` to construct the destination view hierarchy and inject its dependencies, passing it back to the Flow to be pushed onto the navigation stack.

## 3. Navigation Flow
The app's startup routing follows this sequence:
1. **SceneDelegate**: Intercepts app launch, configures the `UIWindow`, and instantiates the `DefaultAppFlow`.
2. **AppFlow (Root Coordinator)**: In its `start()` method, it triggers the `showMainFlow()` routine.
3. **MainFlow (Sub-Coordinator)**: Constructed and retained by `AppFlow`. Calling `start()` triggers `showMainView(with: MainModel())`.
4. **MainModule Initialization**: The Swinject `ModuleAssembly` injects `MainModel` into `MainViewModel`, wraps the SwiftUI `MainViewUI` inside `MainViewController`, and binds their Combine pipelines.
5. **Display**: `MainViewController` (a `BaseHostingController`) is set as the root of the navigation stack, rendering the SwiftUI screen.

## 4. Web Module Architecture
The bridge between the native iOS layer and the HTML5 Canvas relies on a strictly typed, unidirectional data flow governed by the `WebViewModel`.
- **Single Source of Truth**: The `WebViewModel` acts as the definitive state engine for the web layer, ensuring consistency across the hybrid environment.
- **Strict Concurrency**: Annotated with `@MainActor`, it guarantees that all UI updates, state modifications, and JSON parsing occur safely on the main thread, adhering to modern Swift concurrency guidelines.
- **State Tracking & History**: It actively monitors the canvas lifecycle (`isCanvasReady`) and user interaction history (e.g., `lastTappedCoordinates` for driving native haptics).
- **Centralized Dispatch**: All commands sent to the JavaScript environment are strictly modeled as generic `CanvasCommand` payloads and encoded/decoded centrally to prevent malformed data transactions.

## 5. JavaScript Engine
The HTML5 web layer is not a static DOM tree, but a fully reactive rendering engine.
- **Render Loop**: The canvas uses an active rendering loop, clearing and redrawing its contents dynamically based on its internal state.
- **Object-Based State Array**: Instead of immediate-mode painting, the canvas maintains an internal state array (`shapes`) containing all geometric objects and their properties. The render loop iterates over this array to draw the scene.
- **History Management**: To support complex editing features, the engine employs an `undoStack` and `redoStack`. Changes to the `shapes` array are recorded as immutable snapshots, enabling robust undo/redo capabilities without native intervention.

## 6. Presentation Layer & Integration Points
To integrate the hybrid canvas into the native application:
- **Core Wrapper**: The `WebViewUI` module (`CanvasBridge/CanvasBridge/Modules/Web/`) wraps `WKWebView` inside a `UIViewRepresentable`, suppressing native scrolling and applying transparency to blend perfectly with SwiftUI.
- **CanvasToolbarUI**: A decoupled, highly polished, glassmorphic SwiftUI component residing in the Main module. It acts as the primary control surface overlaid on the canvas. It observes the `WebViewModel` to dispatch commands (like adding shapes) down to the JavaScript engine.
- **Assembly Registration**: The web dependencies and the Main module composition are wired together inside `ModuleAssembly.swift` to ensure dependency injection remains intact.
