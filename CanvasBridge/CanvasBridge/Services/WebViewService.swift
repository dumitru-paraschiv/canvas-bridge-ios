//
//  WebViewService.swift
//  CanvasBridge
//
//  Created by Dumitru Paraschiv on 07.05.2026.
//

import WebKit

@MainActor
final class WebViewService {
    
    private let webView: WKWebView
    
    init() {
        // 1. Configure the WKWebView
        let userContentController = WKUserContentController()
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        
        // 2. Make the web view feel native (transparent, no scrolling)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        
        self.webView = webView
        
        // 3. Load the local index.html file from the App Bundle immediately to pre-warm the engine
        if let url = Bundle.main.url(forResource: "index", withExtension: "html") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        } else {
            trace("⚠️ Error: index.html not found in the App Bundle.")
        }
    }
    
    func getWebView() -> WKWebView {
        return webView
    }
}
