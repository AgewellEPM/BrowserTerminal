import Foundation
import WebKit

final class WebViewRegistry {
    static let shared = WebViewRegistry()

    private class WeakWebView {
        weak var value: WKWebView?
        init(_ value: WKWebView) { self.value = value }
    }

    private var storage: [UUID: WeakWebView] = [:]
    private let queue = DispatchQueue(label: "webview.registry", qos: .userInitiated)

    func register(_ webView: WKWebView, for tabId: UUID) {
        queue.async {
            self.storage[tabId] = WeakWebView(webView)
        }
    }

    func unregister(tabId: UUID) {
        queue.async {
            self.storage.removeValue(forKey: tabId)
        }
    }

    func webView(for tabId: UUID) -> WKWebView? {
        var result: WKWebView?
        queue.sync {
            result = self.storage[tabId]?.value
            // Clean up if deallocated
            if self.storage[tabId]?.value == nil {
                self.storage.removeValue(forKey: tabId)
            }
        }
        return result
    }
}

