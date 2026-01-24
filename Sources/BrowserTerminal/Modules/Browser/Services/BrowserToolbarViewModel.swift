import Foundation
import Combine

class BrowserToolbarViewModel: ObservableObject {
    @Published var urlText: String = ""
    @Published var isEditing: Bool = false
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    @Published var isLoading: Bool = false
    @Published var isSecure: Bool = false

    weak var browserManager: BrowserManager?
    private var currentTab: BrowserTab?

    func updateFromTab(_ tab: BrowserTab?) {
        currentTab = tab
        if !isEditing {
            urlText = tab?.url.absoluteString ?? ""
        }
        canGoBack = tab?.canGoBack ?? false
        canGoForward = tab?.canGoForward ?? false
        isLoading = tab?.isLoading ?? false
        isSecure = tab?.url.scheme == "https"
    }

    func goBack() {
        guard let browserManager = browserManager,
              let tabId = browserManager.activeTabId,
              let webView = WebViewRegistry.shared.webView(for: tabId) else { return }
        if webView.canGoBack { webView.goBack() }
    }

    func goForward() {
        guard let browserManager = browserManager,
              let tabId = browserManager.activeTabId,
              let webView = WebViewRegistry.shared.webView(for: tabId) else { return }
        if webView.canGoForward { webView.goForward() }
    }

    func reload() {
        guard let tab = currentTab else { return }
        tab.navigate(to: tab.url)
    }

    func navigateToURL() {
        var urlString = urlText.trimmingCharacters(in: .whitespacesAndNewlines)

        // Add scheme if missing
        if !urlString.contains("://") {
            if urlString.contains(".") {
                urlString = "https://" + urlString
            } else {
                // Treat as search
                urlString = "https://www.google.com/search?q=" +
                    urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            }
        }

        if let url = URL(string: urlString) {
            // Update the current tab if available, or create a new one
            if let tab = currentTab {
                tab.navigate(to: url)
            } else if let browserManager = browserManager {
                // Create a new tab if no current tab
                browserManager.addTab(url: url)
            }
            isEditing = false
        }
    }
}
