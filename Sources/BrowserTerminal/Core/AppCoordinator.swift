import SwiftUI
import Combine

class AppCoordinator: ObservableObject {
    static let shared = AppCoordinator()

    @Published var browserManager: BrowserManager
    @Published var terminalManager: TerminalManager
    @Published var bridgeService: BridgeService
    @Published var splitRatio: CGFloat = 0.6

    private var cancellables = Set<AnyCancellable>()

    init() {
        self.browserManager = BrowserManager()
        self.terminalManager = TerminalManager()
        self.bridgeService = BridgeService()

        setupBindings()
    }

    private func setupBindings() {
        // Set up communication between browser and terminal
        bridgeService.browserManager = browserManager
        bridgeService.terminalManager = terminalManager
    }

    func cleanup() {
        terminalManager.cleanup()
        browserManager.cleanup()
    }
}