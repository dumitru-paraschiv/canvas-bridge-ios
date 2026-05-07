//
//  WebModels.swift
//  CanvasBridge
//
//  Created by Dumitru Paraschiv on 07.05.2026.
//

import Foundation

// MARK: - Incoming (JS to Swift)

/// Represents events sent from the Web Canvas to the Swift native layer.
enum CanvasEvent: Decodable {
    case lifecycle(status: String)
    case userInteraction(nodeID: String, x: Double, y: Double)
    case unknown(String)
    
    private enum CodingKeys: String, CodingKey {
        case event
        case payload
    }
    
    // Nested structs for expected payloads to assist with decoding
    private struct LifecyclePayload: Decodable {
        let status: String
    }
    
    private struct UserInteractionPayload: Decodable {
        let nodeID: String
        let x: Double
        let y: Double
        
        enum CodingKeys: String, CodingKey {
            case nodeID = "node_id"
            case x
            case y
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let eventType = try container.decode(String.self, forKey: .event)
        
        switch eventType {
        case "lifecycle":
            let payload = try container.decode(LifecyclePayload.self, forKey: .payload)
            self = .lifecycle(status: payload.status)
            
        case "user_interaction":
            let payload = try container.decode(UserInteractionPayload.self, forKey: .payload)
            self = .userInteraction(nodeID: payload.nodeID, x: payload.x, y: payload.y)
            
        default:
            self = .unknown(eventType)
        }
    }
}

// MARK: - Outgoing (Swift to JS)

/// An envelope for sending commands from the Swift native layer to the Web Canvas.
struct CanvasCommand<T: Encodable>: Encodable {
    let action: String
    let payload: T
}

// MARK: Command Payloads

struct DrawShapePayload: Encodable {
    let shapeType: String
    let color: String
    let x: Double
    let y: Double
    let width: Double
    let height: Double
    
    enum CodingKeys: String, CodingKey {
        case shapeType = "shape_type"
        case color
        case x
        case y
        case width
        case height
    }
}

struct ClearCanvasPayload: Encodable {
    let animated: Bool
}
