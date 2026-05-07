//
//  WebModels.swift
//  CanvasBridge
//
//  Created by Dumitru Paraschiv on 07.05.2026.
//

import Foundation

// MARK: - Incoming Communication (JS to Swift)

/// Represents events sent from the Web Canvas layer up to the Swift native layer.
/// This enum strictly defines the expected structure of incoming messages,
/// ensuring robust, type-safe, and predictable communication across the bridge.
enum CanvasEvent: Decodable {
    
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
    
    // MARK: - Decodable Implementation
    
    /// Custom initializer to parse the incoming JSON envelope and decode the appropriate payload
    /// based on the `event` key.
    init(from decoder: Decoder) throws {
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
struct CanvasCommand<T: Encodable>: Encodable {
    
    /// The specific action identifier the web layer should execute (e.g., "add_shape", "clear_canvas").
    let action: String
    
    /// The associated data model required to execute the specified action.
    let payload: T
}

// MARK: - Command Payloads

/// Represents an empty payload for commands that require no parameters (e.g., undo, redo).
struct EmptyPayload: Encodable {}

/// Defines the payload required to add a standard geometric shape to the canvas history.
struct AddShapePayload: Encodable {
    let id: String
    let type: String
    let x: Double
    let y: Double
    let size: Double
    let color: String
}

/// Defines the payload required to update the color context within the canvas engine.
struct ColorPayload: Encodable {
    let hexCode: String
}

/// Defines the payload required to draw a sophisticated, geometric shape directly (legacy).
struct DrawShapePayload: Encodable {
    let id: String
    let type: String
    let x: Double
    let y: Double
    let width: Double
    let height: Double
    let color: String
    let cornerRadius: Double
}

/// Defines the payload required to clear the canvas environment entirely.
struct ClearCanvasPayload: Encodable {
    let animated: Bool
}
