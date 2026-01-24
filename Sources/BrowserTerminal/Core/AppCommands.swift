import SwiftUI

struct AppCommands: Commands {
    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("New Terminal Tab") {
                NotificationCenter.default.post(name: .newTerminalTab, object: nil)
            }
            .keyboardShortcut("t")

            Button("New Browser Tab") {
                NotificationCenter.default.post(name: .newBrowserTab, object: nil)
            }
            .keyboardShortcut("t", modifiers: [.command, .shift])
        }

        CommandMenu("View") {
            Button("Toggle Full Screen") {
                if let window = NSApplication.shared.keyWindow {
                    window.toggleFullScreen(nil)
                }
            }
            .keyboardShortcut("f", modifiers: [.command, .control])

            Divider()

            Button("Reset Split") {
                NotificationCenter.default.post(name: .resetSplitView, object: nil)
            }
            .keyboardShortcut("0", modifiers: [.command, .option])
        }

        CommandMenu("Terminal") {
            Button("Clear Terminal") {
                NotificationCenter.default.post(name: .clearTerminal, object: nil)
            }
            .keyboardShortcut("k")

            Button("Reset Terminal") {
                NotificationCenter.default.post(name: .resetTerminal, object: nil)
            }
            .keyboardShortcut("r", modifiers: [.command, .option])
        }
    }
}

extension Notification.Name {
    static let newTerminalTab = Notification.Name("newTerminalTab")
    static let newBrowserTab = Notification.Name("newBrowserTab")
    static let clearTerminal = Notification.Name("clearTerminal")
    static let resetTerminal = Notification.Name("resetTerminal")
}