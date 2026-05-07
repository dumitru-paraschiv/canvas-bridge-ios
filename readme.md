# CanvasBridge 🌉

A highly polished, production-ready Proof of Concept demonstrating a flawless, bidirectional JSON message bridge between native Swift and a local HTML5/JavaScript canvas.

## Overview
CanvasBridge explores the architectural patterns required to build a scalable native-to-web hybrid application. By isolating the JavaScript render context inside a `WKWebView` and driving all state changes through a pure Swift data engine, this project establishes a foundation that is highly performant, testable, and perfectly primed for future Multiplatform implementation.

## Architectural Highlights
* **MVVM-C & Swinject:** Strict separation of concerns. Navigation is handled by UIKit Coordinators, dependencies are injected via Swinject, and the presentation layer is built entirely in SwiftUI.
* **Structured Concurrency:** Utilizes modern Swift 5.9+ `@MainActor` isolation to guarantee thread-safe UI updates and state mutations.
* **Strict JSON Envelope Protocol:** Bidirectional communication utilizes a strict envelope pattern. Swift `Codable` enums and structs ensure defensive decoding of web events and type-safe command serialization.
* **Decoupled State Engine:** The `WebViewModel` acts as the single source of truth, completely abstracting the `WKWebView` from the SwiftUI presentation layer.
* **Native UX Polish:** The web view seamlessly ignores safe areas (via `viewport-fit=cover`), handles Retina DPI scaling, and triggers native physical haptics (`UIImpactFeedbackGenerator`) synced to web canvas interactions.

## The Bridge Protocol
Communication occurs over two distinct channels:
1.  **Commands (Swift -> JS):** `window.updateCanvasState(jsonString)`
2.  **Events (JS -> Swift):** `window.webkit.messageHandlers.canvasBridge.postMessage(payload)`

State history (Undo/Redo) and object rendering (Shapes/Colors) are fully managed via this strict JSON contract.

## Tech Stack
* **Minimum Deployment:** iOS 16.0
* **UI:** SwiftUI, UIKit (Routing)
* **Web Engine:** WKWebView, HTML5 Canvas, Vanilla JS
* **DI & Testing:** Swinject, Swift Testing