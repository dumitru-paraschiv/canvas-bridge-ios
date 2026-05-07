# Canvas Bridge Protocol

This document defines the strict JSON data contracts for bidirectional communication between the Native Swift layer and the Web UI layer.

## Envelope Architecture
All messages utilize an envelope pattern to ensure predictable parsing.

### 1. Swift to JS (Commands)
Sent via `window.updateCanvasState(jsonString)`.
* `action`: String identifying the operation.
* `payload`: Associated data object.

#### Supported Commands:
- **`add_shape`**
  - **Description**: Adds a new geometric shape to the canvas render loop.
  - **Payload**: `{ id: String, type: String ("rect" or "circle"), x: Double, y: Double, size: Double, color: String }`

- **`clear_canvas`**
  - **Description**: Wipes all current shapes from the canvas state.
  - **Payload**: None required (or `EmptyPayload`).

- **`undo`**
  - **Description**: Reverts the canvas to the previous state snapshot in the history stack.
  - **Payload**: None required.

- **`redo`**
  - **Description**: Restores the next state snapshot from the redo history stack.
  - **Payload**: None required.

- **`change_color`**
  - **Description**: Updates the fill color of the currently selected shape or drawing context.
  - **Payload**: `{ hexCode: String }`

### 2. JS to Swift (Events)
Sent via `window.webkit.messageHandlers.canvasBridge.postMessage(jsonString)`.
* `event`: String identifying the lifecycle or interaction event.
* `payload`: Associated data object.