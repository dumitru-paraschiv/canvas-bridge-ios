//
//  MainViewController.swift
//  CanvasBridge
//
//  Created by Dumitru Paraschiv on 07.05.2026.
//

import Combine
import SwiftUI

final class MainViewController: BaseHostingController<MainViewUI>, MainView {
    
    let steps = PassthroughSubject<MainViewSteps, Never>()
    var viewModel: MainViewInput!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.send(.viewDidLoad)
    }
}

struct MainViewUI: View {
    
    @ObservedObject private var viewModel: MainViewModel
    @ObservedObject private var webViewModel: WebViewModel
    @State private var currentCommand: String?
    
    // Data source for random shapes
    private let shapeColors = [
        "#FF3B30", "#FF9500", "#FFCC00", "#4CD964",
        "#5AC8FA", "#007AFF", "#5856D6", "#FF2D55"
    ]
    
    init(viewModel: MainViewModel,
         webViewModel: WebViewModel,
         currentCommand: String? = nil) {
        self.viewModel = viewModel
        self.webViewModel = webViewModel
        self.currentCommand = currentCommand
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            // Bridge Layer
            WebViewUI(viewModel: webViewModel, outgoingCommand: $currentCommand)
                .ignoresSafeArea()
            
            // Overlay Controls
            VStack {
                Spacer()
                
                Button(action: sendRandomShapeCommand) {
                    Text("Add Shape")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 14)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 5)
                }
                .padding(.bottom, 40)
            }
        }
        // Native Haptic Feedback for Web Canvas Interactions
        .onChange(of: webViewModel.lastTappedCoordinates) { _ in
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }
    
    // MARK: - Actions
    
    private func sendRandomShapeCommand() {
        let randomX = Double.random(in: 20...250)
        let randomY = Double.random(in: 50...500)
        let randomWidth = Double.random(in: 60...120)
        let randomHeight = Double.random(in: 60...120)
        let randomRadius = Double.random(in: 4...24)
        let randomColor = shapeColors.randomElement() ?? "#FFFFFF"
        let randomId = UUID().uuidString
        
        let payload = DrawShapePayload(
            id: randomId,
            type: "rounded_rect",
            x: randomX,
            y: randomY,
            width: randomWidth,
            height: randomHeight,
            color: randomColor,
            cornerRadius: randomRadius
        )
        
        let command = CanvasCommand(action: "draw_shape", payload: payload)
        
        if let jsonString = webViewModel.generateCommandString(for: command) {
            currentCommand = jsonString
        }
    }
}
