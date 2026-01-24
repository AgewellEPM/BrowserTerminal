import WebKit

class WebViewFactory {
    static func createWebView(coordinator: BrowserWebViewCoordinator, bridgeService: BridgeService) -> WKWebView {
        let configuration = WKWebViewConfiguration()

        // Enable JavaScript and other web features
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = false

        // Set up web preferences
        configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")

        // Set up message handlers for JavaScript bridge
        configuration.userContentController.add(
            coordinator,
            name: "terminalBridge"
        )

        // Inject JavaScript for terminal integration
        let script = WKUserScript(
            source: JavaScriptBridge.bridgeScript,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
        configuration.userContentController.addUserScript(script)

        let webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 800, height: 600), configuration: configuration)
        webView.navigationDelegate = coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsMagnification = true

        return webView
    }
}