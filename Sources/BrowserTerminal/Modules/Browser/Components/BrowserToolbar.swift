import SwiftUI

struct BrowserToolbar: View {
    @EnvironmentObject var browserManager: BrowserManager
    @StateObject private var viewModel = BrowserToolbarViewModel()

    var body: some View {
        HStack(spacing: 8) {
            NavigationControls(viewModel: viewModel)
            URLField(viewModel: viewModel)
            TabSelector(browserManager: browserManager)
            TerminalIntegrationButton()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(NSColor.windowBackgroundColor))
        .onReceive(browserManager.$activeTabId) { _ in
            viewModel.updateFromTab(browserManager.tabs.first { $0.id == browserManager.activeTabId })
        }
        .onAppear {
            viewModel.browserManager = browserManager
            viewModel.updateFromTab(browserManager.tabs.first { $0.id == browserManager.activeTabId })
        }
    }
}