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
4. **MainModule Initialization**: The Swinject `ModuleAssembly` injects `MainModel` into `MainViewModel`, wraps the SwiftUI `MainViewUI` (which currently displays `Text("Main")`) inside `MainViewController`, and binds their Combine pipelines.
5. **Display**: `MainViewController` (a `BaseHostingController`) is set as the root of the navigation stack, rendering the current blank SwiftUI screen.

## 4. Integration Points
To integrate a new `WKWebView` Representable and its corresponding ViewModel:
- **Target Module Folder**: Create a new module inside `CanvasBridge/CanvasBridge/Modules/` (e.g., `CanvasBridge/CanvasBridge/Modules/Web/`).
- **Implementation Structure**: 
  - Implement a `WebViewUI` conforming to `UIViewRepresentable` to bridge `WKWebView` into SwiftUI.
  - Implement `WebViewModel`, `WebViewController` (inheriting from `BaseHostingController<WebViewUI>`), and `WebModel`.
- **Dependency Registration**: Add the new module assembly definition inside `CanvasBridge/CanvasBridge/Dependencies/ModuleAssembly.swift` to handle its DI.
- **Routing**: Extend `MainFlow` (or create a new `WebFlow`) and add routing steps in `MainViewSteps` to trigger navigation to the new Web view from the Main screen.
