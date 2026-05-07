import Foundation
import Combine
import CoreGraphics

/// Manages the state and communication bridge between the native layer and the Web Canvas.
@MainActor
public final class CanvasStateEngine: ObservableObject {
    
    /// Indicates whether the web canvas has finished initializing and is ready to receive commands.
    @Published public var isCanvasReady: Bool = false
    
    /// Stores the exact coordinates of the user's last interaction with the canvas.
    @Published public var lastTappedCoordinates: CGPoint? = nil
    
    /// Centralized binding to safely dispatch encoded JSON commands to the Web layer.
    @Published public var outgoingCommand: String? = nil
    
    /// The latest captured snapshot of the canvas as Data.
    @Published public var snapshotData: Data? = nil
    
    /// A trigger used to signal the UI layer to capture a snapshot.
    @Published public var triggerSnapshot: Bool = false
    
    /// Indicates if there was a connection or navigation error.
    @Published public var connectionError: String? = nil
    
    /// Indicates whether the WebContent process has crashed or terminated.
    @Published public var isProcessTerminated: Bool = false
    
    /// A trigger used to signal the UI layer to reload the canvas environment.
    @Published public var triggerReload: Bool = false
    
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    private var cancellables = Set<AnyCancellable>()
    
    private let storage: StorageProvider
    
    public init(storage: StorageProvider) {
        self.storage = storage
    }
    
    // MARK: - Incoming Communication (JS -> Swift)
    
    /// Decodes and handles incoming messages from the JavaScript environment.
    /// - Parameter jsonString: The raw JSON string received from WKScriptMessageHandler.
    public func handleIncomingMessage(_ jsonString: String) {
        guard let data = jsonString.data(using: .utf8) else {
            print("⚠️ Error: Failed to convert incoming string to UTF-8 Data.")
            return
        }
        
        do {
            let event = try decoder.decode(CanvasEvent.self, from: data)
            processEvent(event)
        } catch {
            print("❌ Decoding Error: Failed to decode CanvasEvent from JSON.")
            print("   JSON Payload: \(jsonString)")
            print("   Underlying Error: \(error.localizedDescription)")
            print("   Detailed Error: \(error)") // Useful for debugging specific key mismatches
        }
    }
    
    /// Updates the internal state based on the decoded event.
    private func processEvent(_ event: CanvasEvent) {
        switch event {
        case let .lifecycle(status):
            if status == "initialized" || status == "ready" {
                isCanvasReady = true
                print("✅ Canvas Lifecycle: Status is '\(status)'. Bridge is ready.")
                
                // Automatically attempt to restore previous state from disk
                attemptStateHydration()
            } else {
                print("ℹ️ Canvas Lifecycle Update: \(status)")
            }
            
        case let .interaction(type, nodeId, x, y):
            let point = CGPoint(x: x, y: y)
            lastTappedCoordinates = point
            print("👆 Canvas Interaction: User performed '\(type)' on node '\(nodeId)' at \(point).")
            
        case let .syncState(shapes):
            print("💾 State Sync: Received \(shapes.count) shapes from Canvas. Writing to disk...")
            Task {
                do {
                    let data = try encoder.encode(shapes)
                    try storage.saveData(data)
                    print("✅ State Sync: Successfully persisted state to disk.")
                } catch {
                    print("❌ State Sync Error: Failed to write state to disk. \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - State Hydration
    
    /// Attempts to read the saved canvas state from disk and hydrate the JavaScript rendering engine.
    private func attemptStateHydration() {
        Task {
            do {
                guard let data = try storage.loadData() else {
                    print("ℹ️ Hydration: No saved state found on disk. Booting fresh canvas.")
                    return
                }
                
                let shapes = try decoder.decode([ShapePayload].self, from: data)
                
                print("💧 Hydration: Loaded \(shapes.count) shapes from disk. Dispatching to WebContent...")
                let payload = HydrateStatePayload(shapes: shapes)
                let command = CanvasCommand(action: "hydrate_state", payload: payload)
                outgoingCommand = generateCommandString(for: command)
            } catch {
                print("❌ Hydration Error: Failed to load or decode saved state. Booting fresh canvas. \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Outgoing Command Dispatch Helpers
    
    public func addShape(type: String, color: String) {
        let payload = AddShapePayload(
            id: UUID().uuidString,
            type: type,
            x: Double.random(in: 40...300),
            y: Double.random(in: 100...600),
            size: Double.random(in: 50...120),
            color: color
        )
        let command = CanvasCommand(action: "add_shape", payload: payload)
        outgoingCommand = generateCommandString(for: command)
    }
    
    public func undo() {
        let command = CanvasCommand(action: "undo", payload: EmptyPayload())
        outgoingCommand = generateCommandString(for: command)
    }
    
    public func redo() {
        let command = CanvasCommand(action: "redo", payload: EmptyPayload())
        outgoingCommand = generateCommandString(for: command)
    }
    
    public func clear() {
        let command = CanvasCommand(action: "clear_canvas", payload: EmptyPayload())
        outgoingCommand = generateCommandString(for: command)
    }
    
    public func updateColor(hex: String) {
        let payload = ColorPayload(hexCode: hex)
        let command = CanvasCommand(action: "change_color", payload: payload)
        outgoingCommand = generateCommandString(for: command)
    }
    
    // MARK: - Snapshot Handling
    
    /// Triggers the UI to capture a snapshot of the canvas.
    public func requestSnapshot() {
        triggerSnapshot = true
    }
    
    /// Called by the UI layer when a snapshot is successfully captured.
    public func didCaptureSnapshot(_ data: Data) {
        snapshotData = data
        triggerSnapshot = false
    }
    
    // MARK: - Process Monitoring
    
    /// Called when the underlying WKWebView WebContent process unexpectedly terminates.
    public func handleProcessTermination() {
        isCanvasReady = false
        isProcessTerminated = true
        connectionError = "The WebContent process terminated unexpectedly."
        print("🔄 Process Reset: Resetting canvas state due to termination. UI should attempt reload.")
    }
    
    /// Sets a flag to trigger the UI layer to reload the pre-warmed WebView environment.
    public func reloadCanvas() {
        isProcessTerminated = false
        connectionError = nil
        triggerReload = true
    }
    
    // MARK: - Jetsam Mitigation
    
    /// Triggered natively by iOS during memory pressure. Instructs the JS layer to purge non-critical memory.
    public func triggerMemoryPurge() {
        print("⚠️ Jetsam Mitigation: Emitting PURGE_HISTORY to WebContent process")
        let payload = SystemWarningPayload(instruction: "purge_history")
        let command = CanvasCommand(action: "system_warning", payload: payload)
        outgoingCommand = generateCommandString(for: command)
    }
    
    // MARK: - Outgoing Communication (Swift -> JS)
    
    /// Encodes a command into a JSON string to be sent to the Web Canvas.
    /// - Parameter command: The strongly-typed CanvasCommand to send.
    /// - Returns: A JSON string representation of the command, or nil if encoding fails.
    public func generateCommandString<T: Encodable>(for command: CanvasCommand<T>) -> String? {
        do {
            let data = try encoder.encode(command)
            guard let jsonString = String(data: data, encoding: .utf8) else {
                print("⚠️ Encoding Error: Failed to convert encoded JSON data to a UTF-8 String.")
                return nil
            }
            return jsonString
        } catch {
            print("❌ Encoding Error: Failed to encode CanvasCommand into JSON.")
            print("   Command Action: \(command.action)")
            print("   Underlying Error: \(error.localizedDescription)")
            print("   Detailed Error: \(error)")
            return nil
        }
    }
}
