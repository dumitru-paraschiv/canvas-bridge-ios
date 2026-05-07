//
//  CanvasToolbarUI.swift
//  CanvasBridge
//
//  Created by Dumitru Paraschiv on 07.05.2026.
//

import SwiftUI

struct CanvasToolbarUI: View {
    
    @ObservedObject var viewModel: WebViewModel
    
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
        HStack(spacing: 22) {
            // Undo Button
            Button {
                viewModel.undo()
            } label: {
                Image(systemName: "arrow.uturn.backward")
                    .font(.title2)
            }
            .disabled(!viewModel.isCanvasReady)
            
            // Redo Button
            Button {
                viewModel.redo()
            } label: {
                Image(systemName: "arrow.uturn.forward")
                    .font(.title2)
            }
            .disabled(!viewModel.isCanvasReady)
            
            Divider()
                .frame(height: 24)
            
            // Add Square Button
            Button {
                viewModel.addShape(type: "rect", color: shapeColorsHex[colorIndex])
            } label: {
                Image(systemName: "square.fill")
                    .font(.title2)
                    .foregroundColor(shapeColors[colorIndex])
            }
            
            // Add Circle Button
            Button {
                viewModel.addShape(type: "circle", color: shapeColorsHex[colorIndex])
            } label: {
                Image(systemName: "circle.fill")
                    .font(.title2)
                    .foregroundColor(shapeColors[colorIndex])
            }
            
            Divider()
                .frame(height: 24)
            
            // Color Toggle Button
            Button {
                colorIndex = (colorIndex + 1) % shapeColorsHex.count
                viewModel.updateColor(hex: shapeColorsHex[colorIndex])
            } label: {
                Image(systemName: "paintpalette")
                    .font(.title2)
                    .foregroundColor(shapeColors[colorIndex])
            }
            
            // Clear Button
            Button {
                viewModel.clear()
            } label: {
                Image(systemName: "trash")
                    .font(.title2)
                    .foregroundColor(.red)
            }
            .disabled(!viewModel.isCanvasReady)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial)
        .clipShape(.capsule)
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
    }
}
