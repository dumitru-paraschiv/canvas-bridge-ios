//
//  CanvasToolbarUI.swift
//  CanvasBridge
//
//  Created by Dumitru Paraschiv on 07.05.2026.
//

import SwiftUI
import CanvasBridgeCore

struct CanvasToolbarUI: View {
    
    @ObservedObject var engine: CanvasStateEngine
    
    // Data source for cycling colors
    private let shapeColorsHex = [
        "#FFFFFF", "#FF3B30", "#FF9500", "#FFCC00", 
        "#4CD964", "#007AFF", "#AF52DE", "#FF2D55"
    ]
    private let shapeColors: [Color] = [
        .white, .red, .orange, .yellow, 
        .green, .blue, .purple, .pink
    ]
    
    @State private var colorIndex = 0
    
    var body: some View {
        HStack(spacing: 8) {
            
            // MARK: - Group 1: History
            HStack(spacing: 16) {
                Button {
                    engine.undo()
                } label: {
                    Image(systemName: "arrow.uturn.backward")
                }
                .disabled(!engine.isCanvasReady)
                
                Button {
                    engine.redo()
                } label: {
                    Image(systemName: "arrow.uturn.forward")
                }
                .disabled(!engine.isCanvasReady)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            
            Spacer(minLength: 0)
            
            // MARK: - Group 2: Creation & Tooling
            HStack(spacing: 20) {
                Button {
                    engine.addShape(type: "rect", color: shapeColorsHex[colorIndex])
                } label: {
                    Image(systemName: "square.fill")
                        .foregroundColor(shapeColors[colorIndex])
                }
                
                Button {
                    engine.addShape(type: "circle", color: shapeColorsHex[colorIndex])
                } label: {
                    Image(systemName: "circle.fill")
                        .foregroundColor(shapeColors[colorIndex])
                }
                
                Button {
                    colorIndex = (colorIndex + 1) % shapeColorsHex.count
                    engine.updateColor(hex: shapeColorsHex[colorIndex])
                } label: {
                    Image(systemName: "paintpalette")
                        .foregroundColor(shapeColors[colorIndex])
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            
            Spacer(minLength: 0)
            
            // MARK: - Group 3: Destructive / Export Actions
            HStack(spacing: 16) {
                Button {
                    engine.requestSnapshot()
                } label: {
                    Image(systemName: "camera.viewfinder")
                }
                .disabled(!engine.isCanvasReady)
                
                Button {
                    engine.clear()
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .disabled(!engine.isCanvasReady)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            
        }
        .controlSize(.regular)
        .font(.title3) // Standardize icon sizes across the toolbar
        .padding(.horizontal, 16) // Prevent the grouped capsules from touching screen edges
    }
}
