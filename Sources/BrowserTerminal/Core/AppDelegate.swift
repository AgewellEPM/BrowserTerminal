import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set up any app-wide configurations
        NSApplication.shared.windows.first?.titlebarAppearsTransparent = false

        // Activate the app to ensure it can receive keyboard input
        NSApplication.shared.activate(ignoringOtherApps: true)

        // Ensure the first window is key and main
        if let window = NSApplication.shared.windows.first {
            window.makeKeyAndOrderFront(nil)
            window.makeMain()
        }
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        // Ensure the terminal view becomes first responder when app becomes active
        if let window = NSApplication.shared.windows.first,
           let contentView = window.contentView {
            // Find the terminal view and make it first responder
            findAndFocusTerminal(in: contentView, window: window)
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Clean up any resources
        AppCoordinator.shared.cleanup()
    }

    private func findAndFocusTerminal(in view: NSView, window: NSWindow) {
        // Recursively find LocalProcessTerminalView and make it first responder
        if NSStringFromClass(type(of: view)).contains("LocalProcessTerminalView") {
            window.makeFirstResponder(view)
            return
        }

        for subview in view.subviews {
            findAndFocusTerminal(in: subview, window: window)
        }
    }
}