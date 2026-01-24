import SwiftUI
import WebKit

struct BrowserWebView: NSViewRepresentable {
    @ObservedObject var tab: BrowserTab
    @EnvironmentObject var bridgeService: BridgeService

    func makeNSView(context: Context) -> WKWebView {
        let webView = WebViewFactory.createWebView(
            coordinator: context.coordinator,
            bridgeService: bridgeService
        )

        // Track this webview for navigation control
        WebViewRegistry.shared.register(webView, for: tab.id)

        // Load initial URL
        let request = URLRequest(url: tab.url)
        webView.load(request)

        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        if webView.url != tab.url {
            let request = URLRequest(url: tab.url)
            webView.load(request)
        }
    }

    func makeCoordinator() -> BrowserWebViewCoordinator {
        BrowserWebViewCoordinator(tab: tab)
    }
}
