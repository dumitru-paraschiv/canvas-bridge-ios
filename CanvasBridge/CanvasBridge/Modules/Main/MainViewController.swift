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
            WebViewUI(
                viewModel: webViewModel,
                outgoingCommand: $webViewModel.outgoingCommand,
                webViewService: webViewModel.webViewService
            )
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
        // Share Sheet for exporting Canvas Snapshot
        .sheet(isPresented: Binding(
            get: { webViewModel.snapshotImage != nil },
            set: { if !$0 { webViewModel.snapshotImage = nil } }
        )) {
            if let image = webViewModel.snapshotImage {
                ShareSheet(items: [image])
            }
        }
    }
}

// MARK: - Share Sheet Helper

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
