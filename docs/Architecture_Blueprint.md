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
  - `ServiceAssembly`: Registers shared services and resource-heavy process managers. Notably, `WebViewService` is registered as a Singleton (`.container` scope) to ensure the web engine boots exactly once and is readily accessible to the Main module.
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
- **State Tracking & History**: It actively monitors the canvas lifecycle (`isCanvasReady`) and user interaction history (e.g., `lastTappedCoordinates` for driving native haptics). It also manages transient states, such as `triggerSnapshot` and `snapshotImage`, to coordinate complex asynchronous operations.
- **Centralized Dispatch**: All commands sent to the JavaScript environment are strictly modeled as generic `CanvasCommand` payloads and encoded/decoded centrally to prevent malformed data transactions.
- **Asynchronous Snapshot Flow**: To export the canvas, the `WebViewModel` toggles a `triggerSnapshot` flag. The `WebViewUI` actively observes this state, invokes the native `WKWebView.takeSnapshot(with: nil)` API to capture the out-of-process web buffer, and asynchronously returns a native `UIImage` back to the ViewModel.

## 5. JavaScript Engine
The HTML5 web layer is not a static DOM tree, but a fully reactive rendering engine.
- **Render Loop**: The canvas uses an active rendering loop, clearing and redrawing its contents dynamically based on its internal state.
- **Object-Based State Array**: Instead of immediate-mode painting, the canvas maintains an internal state array (`shapes`) containing all geometric objects and their properties. The render loop iterates over this array to draw the scene.
- **History Management**: To support complex editing features, the engine employs an `undoStack` and `redoStack`. Changes to the `shapes` array are recorded as immutable snapshots, enabling robust undo/redo capabilities without native intervention.

## 6. Presentation Layer & Integration Points
To integrate the hybrid canvas into the native application:
- **Core Wrapper**: The `WebViewUI` module (`CanvasBridge/CanvasBridge/Modules/Web/`) wraps `WKWebView` inside a `UIViewRepresentable`, suppressing native scrolling and applying transparency to blend perfectly with SwiftUI.
- **CanvasToolbarUI**: A highly polished, glassmorphic SwiftUI component residing in the Main module. It utilizes a **Grouped Contextual Design**—segmented into distinct capsules for History, Creation, and Output—to optimize for HIG-compliant hit targets and information architecture. It observes the `WebViewModel` to dispatch commands down to the JavaScript engine and trigger native actions like snapshots.
- **Assembly Registration**: The web dependencies and the Main module composition are wired together inside `ModuleAssembly.swift` to ensure dependency injection remains intact.

## 7. Service Layer & Pre-Warming
To eliminate latency and "white-flash" artifacts when loading the hybrid environment, the application utilizes a `WebViewService`.
- **Pre-Initialization**: The `WebViewService` instantly initializes the `WKWebView` and triggers the WebContent process to load the HTML/JS assets during the app's launch sequence, completely decoupled from UI navigation.
- **Lifecycle Optimization**: By the time the user navigates to the canvas screen, the JavaScript rendering engine has already booted in the background. The `WebViewUI` simply requests this pre-warmed instance, resulting in instantaneous native-level transition speeds.
