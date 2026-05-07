# Canvas Bridge Protocol

This document defines the strict JSON data contracts for bidirectional communication between the Native Swift layer and the Web UI layer.

## Envelope Architecture
All messages utilize an envelope pattern to ensure predictable parsing.

### 1. Swift to JS (Commands)
Sent via `window.updateCanvasState(jsonString)`.
* `action`: String identifying the operation.
* `payload`: Associated data object.

#### Supported Commands:

**History Group**
- **`undo`**
  - **Description**: Reverts the canvas to the previous state snapshot in the history stack.
  - **Payload**: None required.
- **`redo`**
  - **Description**: Restores the next state snapshot from the redo history stack.
  - **Payload**: None required.

**Manipulation Group**
- **`add_shape`**
  - **Description**: Adds a new geometric shape to the canvas render loop.
  - **Payload**: `{ id: String, type: String ("rect" or "circle"), x: Double, y: Double, size: Double, color: String }`
- **`change_color`**
  - **Description**: Updates the fill color of the currently selected shape or drawing context.
  - **Payload**: `{ hexCode: String }`

**Output Group**
- **`clear_canvas`**
  - **Description**: Wipes all current shapes from the canvas state.
  - **Payload**: None required (or `EmptyPayload`).

### 2. JS to Swift (Events)
Sent via `window.webkit.messageHandlers.canvasBridge.postMessage(jsonString)`.
* `event`: String identifying the lifecycle or interaction event.
* `payload`: Associated data object.

### 3. Native-Only Actions
Certain architectural operations are performed entirely on the native layer and bypass the JSON messaging bridge:
- **Snapshotting**: Triggered natively via the `takeSnapshot(with:)` API directly on the `WKWebView`. This operation securely captures the out-of-process web buffer into a native `UIImage`, relying purely on the static state of the HTML5 canvas at the exact moment of capture without necessitating any JS-side execution or payload overhead.