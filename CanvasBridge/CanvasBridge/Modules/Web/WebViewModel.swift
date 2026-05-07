//
//  WebViewModel.swift
//  CanvasBridge
//
//  Created by Dumitru Paraschiv on 07.05.2026.
//

import Foundation
import Combine
import CoreGraphics

/// Manages the state and communication bridge between the native layer and the Web Canvas.
@MainActor
final class WebViewModel: ObservableObject {
    
    /// Indicates whether the web canvas has finished initializing and is ready to receive commands.
    @Published var isCanvasReady: Bool = false
    
    /// Stores the exact coordinates of the user's last interaction with the canvas.
    @Published var lastTappedCoordinates: CGPoint? = nil
    
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
            trace("⚠️ Error: Failed to convert incoming string to UTF-8 Data.")
            return
        }
        
        do {
            let event = try decoder.decode(CanvasEvent.self, from: data)
            processEvent(event)
        } catch {
            trace("❌ Decoding Error: Failed to decode CanvasEvent from JSON.")
            trace("   JSON Payload: \(jsonString)")
            trace("   Underlying Error: \(error.localizedDescription)")
            trace("   Detailed Error: \(error)") // Useful for debugging specific key mismatches
        }
    }
    
    /// Updates the internal state based on the decoded event.
    private func processEvent(_ event: CanvasEvent) {
        switch event {
        case let .lifecycle(status):
            if status == "initialized" || status == "ready" {
                isCanvasReady = true
                trace("✅ Canvas Lifecycle: Status is '\(status)'. Bridge is ready.")
            } else {
                trace("ℹ️ Canvas Lifecycle Update: \(status)")
            }
            
        case let .interaction(type, nodeId, x, y):
            let point = CGPoint(x: x, y: y)
            lastTappedCoordinates = point
            trace("👆 Canvas Interaction: User performed '\(type)' on node '\(nodeId)' at \(point).")
        }
    }
    
    // MARK: - Outgoing Communication (Swift -> JS)
    
    /// Encodes a command into a JSON string to be sent to the Web Canvas.
    /// - Parameter command: The strongly-typed CanvasCommand to send.
    /// - Returns: A JSON string representation of the command, or nil if encoding fails.
    func generateCommandString<T: Encodable>(for command: CanvasCommand<T>) -> String? {
        do {
            let data = try encoder.encode(command)
            guard let jsonString = String(data: data, encoding: .utf8) else {
                trace("⚠️ Encoding Error: Failed to convert encoded JSON data to a UTF-8 String.")
                return nil
            }
            return jsonString
        } catch {
            trace("❌ Encoding Error: Failed to encode CanvasCommand into JSON.")
            trace("   Command Action: \(command.action)")
            trace("   Underlying Error: \(error.localizedDescription)")
            trace("   Detailed Error: \(error)")
            return nil
        }
    }
}
