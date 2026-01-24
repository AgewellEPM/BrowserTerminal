import Foundation
import Combine

class BrowserManager: ObservableObject {
    @Published var tabs: [BrowserTab] = []
    @Published var activeTabId: UUID?

    private var cancellables = Set<AnyCancellable>()

    init() {
        addTab()
        setupNotifications()
    }

    private func setupNotifications() {
        NotificationCenter.default.publisher(for: .newBrowserTab)
            .sink { [weak self] _ in
                self?.addTab()
            }
            .store(in: &cancellables)
    }

    func addTab(url: URL? = nil) {
        let tab = BrowserTab(url: url ?? URL(string: "https://www.google.com")!)
        tabs.append(tab)
        activeTabId = tab.id
    }

    func removeTab(id: UUID) {
        tabs.removeAll { $0.id == id }
        if tabs.isEmpty {
            addTab()
        } else if activeTabId == id {
            activeTabId = tabs.first?.id
        }
    }

    func navigateActiveTab(to url: URL) {
        guard let tabId = activeTabId,
              let tab = tabs.first(where: { $0.id == tabId }) else { return }
        tab.navigate(to: url)
    }

    func cleanup() {
        // Clean up resources
        tabs.removeAll()
    }
}