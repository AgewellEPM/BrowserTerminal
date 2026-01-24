import WebKit

class BrowserWebViewCoordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
    var tab: BrowserTab

    init(tab: BrowserTab) {
        self.tab = tab
    }

    // MARK: - WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "terminalBridge",
              let body = message.body as? [String: Any],
              let action = body["action"] as? String else { return }

        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .bridgeMessage,
                object: nil,
                userInfo: ["action": action, "body": body]
            )
        }
    }

    // MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // Allow all navigation including link clicks
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        DispatchQueue.main.async {
            self.tab.isLoading = true
            if let url = webView.url {
                self.tab.url = url
            }
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.async {
            self.tab.isLoading = false
            self.tab.title = webView.title ?? "Untitled"
            self.tab.canGoBack = webView.canGoBack
            self.tab.canGoForward = webView.canGoForward

            if let url = webView.url {
                self.tab.url = url
            }
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        DispatchQueue.main.async {
            self.tab.isLoading = false
        }
    }
}

extension Notification.Name {
    static let bridgeMessage = Notification.Name("bridgeMessage")
}