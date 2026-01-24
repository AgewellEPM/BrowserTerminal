import Foundation
import Combine
import AppKit

class BridgeService: ObservableObject {
    weak var browserManager: BrowserManager?
    weak var terminalManager: TerminalManager?

    private var cancellables = Set<AnyCancellable>()

    init() {
        setupNotifications()
    }

    private func setupNotifications() {
        // Handle bridge messages from browser
        NotificationCenter.default.publisher(for: .bridgeMessage)
            .sink { [weak self] notification in
                self?.handleBridgeMessage(notification)
            }
            .store(in: &cancellables)

        // Handle send URL to terminal
        NotificationCenter.default.publisher(for: .sendURLToTerminal)
            .sink { [weak self] _ in
                self?.sendCurrentURLToTerminal()
            }
            .store(in: &cancellables)

        // Handle copy terminal output
        NotificationCenter.default.publisher(for: .copyTerminalOutput)
            .sink { [weak self] _ in
                self?.copyTerminalOutput()
            }
            .store(in: &cancellables)

        // Handle URL clicks from terminal output
        NotificationCenter.default.publisher(for: .openURLFromTerminal)
            .sink { [weak self] notification in
                guard let urlString = notification.userInfo?["url"] as? String,
                      let url = URL(string: urlString) else { return }
                self?.openInBrowser(url)
            }
            .store(in: &cancellables)
    }

    private func handleBridgeMessage(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let action = userInfo["action"] as? String,
              let body = userInfo["body"] as? [String: Any] else { return }

        switch action {
        case "execute":
            if let command = body["command"] as? String {
                executeInTerminal(command)
            }

        case "openURL":
            if let urlString = body["url"] as? String,
               let url = URL(string: urlString) {
                openInBrowser(url)
            }

        case "send":
            if let data = body["data"] as? String {
                sendToTerminal(data)
            }

        default:
            break
        }
    }

    func executeInTerminal(_ command: String) {
        let cmd = command.hasSuffix("\n") ? command : command + "\n"
        terminalManager?.writeToActiveSession(cmd)
    }

    func openInBrowser(_ url: URL) {
        browserManager?.navigateActiveTab(to: url)
    }

    func sendToTerminal(_ data: String) {
        terminalManager?.writeToActiveSession(data)
    }

    private func sendCurrentURLToTerminal() {
        guard let browserManager = browserManager,
              let tabId = browserManager.activeTabId,
              let tab = browserManager.tabs.first(where: { $0.id == tabId }) else { return }

        executeInTerminal("echo '\(tab.url.absoluteString)'\n")
    }

    private func copyTerminalOutput() {
        guard let terminalManager = terminalManager,
              let sessionId = terminalManager.activeSessionId,
              let session = terminalManager.sessions.first(where: { $0.id == sessionId }) else { return }

        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(session.output, forType: .string)
    }
}
