import SwiftUI

struct BrowserContainer: View {
    @EnvironmentObject var browserManager: BrowserManager
    @EnvironmentObject var bridgeService: BridgeService

    var body: some View {
        VStack(spacing: 0) {
            BrowserToolbar()
                .environmentObject(browserManager)

            if let activeTabId = browserManager.activeTabId,
               let tab = browserManager.tabs.first(where: { $0.id == activeTabId }) {
                BrowserWebView(tab: tab)
                    .environmentObject(bridgeService)
            } else {
                EmptyBrowserView()
            }
        }
    }
}

struct EmptyBrowserView: View {
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "globe")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No browser tab open")
                .font(.headline)
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.controlBackgroundColor))
    }
}