# CanvasBridge 🌉
**Version: v1.3.0**

A highly polished, production-ready Proof of Concept demonstrating a flawless, bidirectional JSON message bridge between native Swift and a local HTML5/JavaScript canvas.

## Overview
CanvasBridge explores the architectural patterns required to build a scalable native-to-web hybrid application. By isolating the JavaScript render context inside a `WKWebView` and driving all state changes through a pure Swift data engine, this project establishes a foundation that is highly performant, testable, and perfectly primed for future Multiplatform implementation.

## Architectural Highlights
* **MVVM-C & Swinject:** Strict separation of concerns. Navigation is handled by UIKit Coordinators, dependencies are injected via Swinject, and the presentation layer is built entirely in SwiftUI.
* **Structured Concurrency:** Utilizes modern Swift 5.9+ `@MainActor` isolation to guarantee thread-safe UI updates and state mutations.
* **Strict JSON Envelope Protocol:** Bidirectional communication utilizes a strict envelope pattern. Swift `Codable` enums and structs ensure defensive decoding of web events and type-safe command serialization.
* **Decoupled State Engine:** The `WebViewModel` acts as the single source of truth, completely abstracting the `WKWebView` from the SwiftUI presentation layer.
* **Native UX Polish & Grouped Contextual Toolbar:** The web view seamlessly ignores safe areas (via `viewport-fit=cover`), handles Retina DPI scaling, and triggers native physical haptics (`UIImpactFeedbackGenerator`) synced to web canvas interactions. The UI features a newly redesigned, glassmorphic Grouped Contextual Toolbar ensuring scalable, HIG-compliant hit targets as the feature set expands.

## Features
* **Security & Resilience:** Implements Strict Navigation Sandboxing to completely block external URL requests and script injections. Features a built-in Renderer Crash Recovery system to detect out-of-process engine terminations and gracefully recover.
* **Advanced WebKit Snapshotting:** Securely captures the out-of-process web buffer directly into a native `UIImage` using asynchronous `WKWebView` APIs, allowing for seamless export and sharing via the native iOS Share Sheet.
* **Reactive Rendering & History:** The canvas engine handles dynamic object placement (Rectangles, Circles), dynamic color palettes, and robust history management via `undoStack` and `redoStack`.

## The Bridge Protocol
Communication occurs over distinct channels:
1.  **Commands (Swift -> JS):** `window.updateCanvasState(jsonString)`
2.  **Events (JS -> Swift):** `window.webkit.messageHandlers.canvasBridge.postMessage(payload)`
3.  **Native-to-Global Capture:** While most manipulations are bidirectional JSON messages, *Snapshotting* leverages a specialized native operation that elegantly bypasses the JSON layer to snapshot the static JS rendering buffer.

State history (Undo/Redo) and object rendering (Shapes/Colors) are fully managed via this strict JSON contract.

## Performance & Optimization
* **Pre-Warming Strategy**: To achieve instantaneous, native-level transition speeds, the `WKWebView` engine is heavily pre-warmed. A dedicated `WebViewService` initializes the WebContent process during the app's launch sequence, entirely decoupling the hybrid environment's load time from UI navigation. This proactively eliminates latency and "white-flash" artifacts.

## Tech Stack
* **Minimum Deployment:** iOS 16.0
* **UI:** SwiftUI, UIKit (Routing)
* **Web Engine:** WKWebView, HTML5 Canvas, Vanilla JS
* **State & Performance:** Singleton services for resource-heavy process management (`WebViewService`).
* **DI & Testing:** Swinject, Swift Testing