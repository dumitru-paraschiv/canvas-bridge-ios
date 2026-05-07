//
//  WebViewUI.swift
//  CanvasBridge
//
//  Created by Dumitru Paraschiv on 07.05.2026.
//

import SwiftUI
import WebKit

@MainActor
struct WebViewUI: UIViewRepresentable {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: WebViewModel
    @Binding var outgoingCommand: String?
    let webViewService: WebViewService
    
    // MARK: - Coordinator Setup
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - UIViewRepresentable
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = webViewService.getWebView()
        
        // Update the WKUserContentController to point to the current Coordinator
        let userContentController = webView.configuration.userContentController
        
        // Remove existing handler to prevent crashes if the view is recreated
        userContentController.removeScriptMessageHandler(forName: "canvasBridge")
        
        // Register the script message handler named "canvasBridge" to intercept JS messages
        userContentController.add(context.coordinator, name: "canvasBridge")
        
        // Assign the navigation delegate for security and process monitoring
        webView.navigationDelegate = context.coordinator
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Handle Swift-to-JS commands
        if let command = outgoingCommand {
            // Evaluate the JS function with the stringified JSON payload
            uiView.evaluateJavaScript("window.updateCanvasState('\(command)')") { _, error in
                if let error = error {
                    trace("⚠️ JS Evaluation Error: \(error.localizedDescription)")
                }
            }
            
            // Asynchronously reset the binding on the MainActor to prevent duplicate execution
            Task { @MainActor in
                self.outgoingCommand = nil
            }
        }
        
        // Handle Snapshot Requests
        if viewModel.triggerSnapshot {
            let capturedViewModel = viewModel
            uiView.takeSnapshot(with: nil) { image, error in
                if let error = error {
                    trace("⚠️ Snapshot Error: \(error.localizedDescription)")
                } else if let image = image {
                    Task { @MainActor in
                        capturedViewModel.didCaptureSnapshot(image)
                    }
                }
            }
        }
        
        // Handle Reload Requests
        if viewModel.triggerReload {
            trace("🔄 WebViewUI: Executing WKWebView reload to recover WebContent process.")
            uiView.reload()
            
            Task { @MainActor in
                self.viewModel.triggerReload = false
            }
        }
    }
    
    // MARK: - Coordinator (WKScriptMessageHandler)
    
    @MainActor
    class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
        
        var parent: WebViewUI
        
        init(_ parent: WebViewUI) {
            self.parent = parent
        }
        
        /// Intercepts messages sent from the JavaScript environment.
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "canvasBridge" {
                if let payloadString = message.body as? String {
                    // Route the string payload to the ViewModel for decoding and state updates
                    parent.viewModel.handleIncomingMessage(payloadString)
                } else {
                    trace("⚠️ Received message body is not a String: \(message.body)")
                }
            }
        }
        
        // MARK: - WKNavigationDelegate Security & Monitoring
        
        /// Enforces strict navigation policies to prevent unauthorized external requests or script injection.
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.cancel)
                return
            }
            
            // Allow only local file URLs originating from the App Bundle
            if url.isFileURL && url.path.hasPrefix(Bundle.main.bundlePath) {
                decisionHandler(.allow)
            } else {
                trace("⚠️ Security Alert: Blocked unauthorized navigation attempt to \(url.absoluteString)")
                decisionHandler(.cancel)
            }
        }
        
        /// Catches and logs errors during local provisional navigation.
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            trace("❌ WebView Error: Failed provisional navigation with error: \(error.localizedDescription)")
        }
        
        /// Detects if the WebContent process crashes (e.g., due to memory pressure).
        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            trace("💥 WebView Crash: The WebContent process terminated unexpectedly.")
            parent.viewModel.handleProcessTermination()
        }
    }
}
