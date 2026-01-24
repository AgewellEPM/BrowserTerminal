import Foundation
import Combine

class BrowserTab: ObservableObject, Identifiable {
    let id = UUID()
    @Published var url: URL
    @Published var title: String = "New Tab"
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    @Published var isLoading: Bool = false

    init(url: URL) {
        self.url = url
    }

    func navigate(to url: URL) {
        self.url = url
    }
}