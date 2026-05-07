//
//  WebViewModel.swift
//  CanvasBridge
//
//  Created by Dumitru Paraschiv on 07.05.2026.
//

import Foundation
import Combine

/// Errors that can occur within the Web Bridge communication.
enum WebBridgeError: Error, LocalizedError {
    
    case stringConversionFailed
    
    var errorDescription: String? {
        switch self {
        case .stringConversionFailed:
            return "Failed to convert encoded JSON data to a UTF-8 String."
        }
    }
}

/// Manages the state and communication bridge between the native layer and the Web Canvas.
@MainActor
final class WebViewModel: ObservableObject {
    
    /// Indicates whether the web canvas has finished initializing and is ready to receive commands.
    @Published var isCanvasReady: Bool = false
    
    /// Stores the ID of the last node the user interacted with on the canvas.
    @Published var lastTappedNode: String? = nil
    
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    init() {
        // Any specific encoder/decoder configurations (e.g., date formats, key strategies) can be set here.
    }
    
    // MARK: - Incoming Communication (JS -> Swift)
    
    /// Decodes and handles incoming messages from the JavaScript environment.
    /// - Parameter jsonString: The raw JSON string received from WKScriptMessageHandler.
    func handleIncomingMessage(_ jsonString: String) {
        guard let data = jsonString.data(using: .utf8) else {
            trace("⚠️ [WebViewModel] Failed to convert incoming string to Data.")
            return
        }
        
        do {
            let event = try decoder.decode(CanvasEvent.self, from: data)
            processEvent(event)
        } catch {
            trace("⚠️ [WebViewModel] Failed to decode CanvasEvent: \(error)")
        }
    }
    
    /// Updates the internal state based on the decoded event.
    private func processEvent(_ event: CanvasEvent) {
        switch event {
        case let .lifecycle(status):
            if status == "initialized" || status == "ready" {
                isCanvasReady = true
                print("✅ [WebViewModel] Canvas is ready.")
            }
            
        case let .userInteraction(nodeID, x, y):
            lastTappedNode = nodeID
            trace("👆 [WebViewModel] User interacted with node '\(nodeID)' at (\(x), \(y)).")
            
        case let .unknown(eventType):
            trace("❓ [WebViewModel] Received unknown event type: \(eventType)")
        }
    }
    
    // MARK: - Outgoing Communication (Swift -> JS)
    
    /// Encodes a command into a JSON string to be sent to the Web Canvas.
    /// - Parameter command: The strongly-typed CanvasCommand to send.
    /// - Returns: A JSON string representation of the command.
    func generateCommandString<T: Encodable>(for command: CanvasCommand<T>) throws -> String {
        let data = try encoder.encode(command)
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw WebBridgeError.stringConversionFailed
        }
        
        return jsonString
    }
}
