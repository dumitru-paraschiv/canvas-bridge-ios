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
    
    @ObservedObject var viewModel: MainViewModel
    @ObservedObject var webViewModel: WebViewModel
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            // Bridge Layer
            WebViewUI(viewModel: webViewModel, outgoingCommand: $webViewModel.outgoingCommand)
                .ignoresSafeArea()
            
            // Overlay Controls
            VStack {
                Spacer()
                
                CanvasToolbarUI(viewModel: webViewModel)
                    .padding(.bottom, 40)
            }
        }
        // Native Haptic Feedback for Web Canvas Interactions
        .onChange(of: webViewModel.lastTappedCoordinates) { _ in
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }
}
