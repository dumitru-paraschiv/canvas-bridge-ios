//
//  MainViewController.swift
//  CanvasBridge
//
//  Created by Dumitru Paraschiv on 07.05.2026.
//

import Combine
import SwiftUI
import CanvasBridgeCore

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
    @ObservedObject var engine: CanvasStateEngine
    let webViewService: WebViewService
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            // Bridge Layer
            WebViewUI(
                engine: engine,
                outgoingCommand: $engine.outgoingCommand,
                webViewService: webViewService
            )
                .ignoresSafeArea()
            
            // Process Recovery Overlay
            if engine.isProcessTerminated {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.orange)
                    
                    Text("Canvas Unresponsive")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    if let error = engine.connectionError {
                        Text(error)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        engine.reloadCanvas()
                    }) {
                        Text("Refresh Engine")
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .clipShape(Capsule())
                    }
                    .padding(.top, 8)
                }
                .padding(32)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
            }
            
            // Overlay Controls
            VStack {
                Spacer()
                
                CanvasToolbarUI(engine: engine)
                    .padding(.bottom, 40)
            }
        }
        // Native Haptic Feedback for Web Canvas Interactions
        .onChange(of: engine.lastTappedCoordinates) { _ in
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
        // Share Sheet for exporting Canvas Snapshot
        .sheet(isPresented: Binding(
            get: { engine.snapshotData != nil },
            set: { if !$0 { engine.snapshotData = nil } }
        )) {
            if let data = engine.snapshotData, let image = UIImage(data: data) {
                ShareSheet(items: [image])
            }
        }
        // Memory Warning Handling (Jetsam Mitigation)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)) { _ in
            engine.triggerMemoryPurge()
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
