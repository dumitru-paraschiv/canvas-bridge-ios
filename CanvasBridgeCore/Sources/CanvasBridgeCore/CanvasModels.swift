import Foundation

// MARK: - Incoming Communication (JS to Swift)

/// Represents events sent from the Web Canvas layer up to the Swift native layer.
/// This enum strictly defines the expected structure of incoming messages,
/// ensuring robust, type-safe, and predictable communication across the bridge.
public enum CanvasEvent: Decodable {
    
    /// Triggered during the initialization phase of the web canvas.
    /// - Parameter status: A string indicating the current status (e.g., "ready").
    case lifecycle(status: String)
    
    /// Triggered when the user interacts with the web canvas.
    /// - Parameters:
    ///   - type: The specific type of interaction (e.g., "tap", "drag", "hover").
    ///   - nodeId: The unique identifier of the interacted node or element on the canvas.
    ///   - x: The precise horizontal coordinate of the interaction relative to the canvas origin.
    ///   - y: The precise vertical coordinate of the interaction relative to the canvas origin.
    case interaction(type: String, nodeId: String, x: Double, y: Double)
    
    /// Triggered when the web layer synchronizes its full state array with the native layer.
    /// - Parameter shapes: An array of currently active shapes on the canvas.
    case syncState(shapes: [ShapePayload])
    
    /// Keys used to decode the outer envelope of the incoming JSON message.
    private enum EnvelopeKeys: String, CodingKey {

        case event
        case payload
    }
    
    /// Keys used to decode the payload of a lifecycle event.
    private enum LifecyclePayloadKeys: String, CodingKey {

        case status
    }
    
    /// Keys used to decode the payload of an interaction event.
    private enum InteractionPayloadKeys: String, CodingKey {

        case type
        case nodeId = "node_id" // Maps the JS snake_case key to Swift camelCase
        case x
        case y
    }
    
    /// Keys used to decode the payload of a sync_state event.
    private enum SyncStatePayloadKeys: String, CodingKey {

        case shapes
    }
    
    // MARK: - Decodable Implementation
    
    /// Custom initializer to parse the incoming JSON envelope and decode the appropriate payload
    /// based on the `event` key.
    public init(from decoder: Decoder) throws {
        // First, extract the outer envelope container
        let envelopeContainer = try decoder.container(keyedBy: EnvelopeKeys.self)
        
        // Decode the primary event type to determine how to parse the payload
        let eventType = try envelopeContainer.decode(String.self, forKey: .event)
        
        switch eventType {
        case "lifecycle":
            // Access the nested payload object for lifecycle events
            let payloadContainer = try envelopeContainer.nestedContainer(keyedBy: LifecyclePayloadKeys.self, forKey: .payload)
            let status = try payloadContainer.decode(String.self, forKey: .status)
            self = .lifecycle(status: status)
            
        case "user_interaction":
            // Access the nested payload object for interaction events
            let payloadContainer = try envelopeContainer.nestedContainer(keyedBy: InteractionPayloadKeys.self, forKey: .payload)
            let type = try payloadContainer.decode(String.self, forKey: .type)
            let nodeId = try payloadContainer.decode(String.self, forKey: .nodeId)
            let x = try payloadContainer.decode(Double.self, forKey: .x)
            let y = try payloadContainer.decode(Double.self, forKey: .y)
            self = .interaction(type: type, nodeId: nodeId, x: x, y: y)
            
        case "sync_state":
            // Access the nested payload object for sync_state events
            let payloadContainer = try envelopeContainer.nestedContainer(keyedBy: SyncStatePayloadKeys.self, forKey: .payload)
            let shapes = try payloadContainer.decode([ShapePayload].self, forKey: .shapes)
            self = .syncState(shapes: shapes)
            
        default:
            // For strict typing in a production environment, throw an error on unknown events
            // to ensure the bridge protocol remains synchronized between JS and Swift.
            throw DecodingError.dataCorruptedError(
                forKey: .event,
                in: envelopeContainer,
                debugDescription: "Unknown or unsupported event type: \(eventType)"
            )
        }
    }
}

// MARK: - Outgoing Communication (Swift to JS)

/// A strictly typed envelope for sending commands from the native Swift layer down to the Web Canvas.
/// By utilizing generics, this struct ensures that any payload sent conforms to standard Encodable requirements.
public struct CanvasCommand<T: Encodable>: Encodable {
    
    /// The specific action identifier the web layer should execute (e.g., "add_shape", "clear_canvas").
    public let action: String
    
    /// The associated data model required to execute the specified action.
    public let payload: T
    
    public init(action: String, payload: T) {
        self.action = action
        self.payload = payload
    }
}

// MARK: - Command Payloads

/// A generic representation of a shape on the canvas, used for state synchronization and hydration.
public struct ShapePayload: Codable, Equatable {

    public let id: String?
    public let type: String
    public let x: Double
    public let y: Double
    public let size: Double?
    public let width: Double?
    public let height: Double?
    public let color: String?
    public let cornerRadius: Double?
    
    public init(id: String?, type: String, x: Double, y: Double, size: Double?, width: Double?, height: Double?, color: String?, cornerRadius: Double?) {
        self.id = id
        self.type = type
        self.x = x
        self.y = y
        self.size = size
        self.width = width
        self.height = height
        self.color = color
        self.cornerRadius = cornerRadius
    }
}

/// Represents an empty payload for commands that require no parameters (e.g., undo, redo).
public struct EmptyPayload: Codable, Equatable {

    public init() {}
}

/// Defines the payload required to add a standard geometric shape to the canvas history.
public struct AddShapePayload: Codable, Equatable {

    public let id: String
    public let type: String
    public let x: Double
    public let y: Double
    public let size: Double
    public let color: String
    
    public init(id: String, type: String, x: Double, y: Double, size: Double, color: String) {
        self.id = id
        self.type = type
        self.x = x
        self.y = y
        self.size = size
        self.color = color
    }
}

/// Defines the payload required to update the color context within the canvas engine.
public struct ColorPayload: Codable, Equatable {

    public let hexCode: String
    
    public init(hexCode: String) {
        self.hexCode = hexCode
    }
}

/// Defines the payload required to draw a sophisticated, geometric shape directly (legacy).
public struct DrawShapePayload: Codable, Equatable {

    public let id: String
    public let type: String
    public let x: Double
    public let y: Double
    public let width: Double
    public let height: Double
    public let color: String
    public let cornerRadius: Double
    
    public init(id: String, type: String, x: Double, y: Double, width: Double, height: Double, color: String, cornerRadius: Double) {
        self.id = id
        self.type = type
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.color = color
        self.cornerRadius = cornerRadius
    }
}

/// Defines the payload required to clear the canvas environment entirely.
public struct ClearCanvasPayload: Codable, Equatable {

    public let animated: Bool
    
    public init(animated: Bool) {
        self.animated = animated
    }
}

/// Defines the payload required to instruct the web layer to perform system-level operations.
public struct SystemWarningPayload: Codable, Equatable {

    public let instruction: String
    
    public init(instruction: String) {
        self.instruction = instruction
    }
}

/// Defines the payload required to hydrate the web engine with a predefined array of shapes.
public struct HydrateStatePayload: Codable, Equatable {
    
    public let shapes: [ShapePayload]
    
    public init(shapes: [ShapePayload]) {
        self.shapes = shapes
    }
}
