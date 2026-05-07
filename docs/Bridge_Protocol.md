# Canvas Bridge Protocol

This document defines the strict JSON data contracts for bidirectional communication between the Native Swift layer and the Web UI layer.

## Envelope Architecture
All messages utilize an envelope pattern to ensure predictable parsing.

### 1. Swift to JS (Commands)
Sent via `window.updateCanvasState(jsonString)`.
* `action`: String identifying the operation.
* `payload`: Associated data object.

### 2. JS to Swift (Events)
Sent via `window.webkit.messageHandlers.canvasBridge.postMessage(jsonString)`.
* `event`: String identifying the lifecycle or interaction event.
* `payload`: Associated data object.