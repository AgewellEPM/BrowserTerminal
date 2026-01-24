import SwiftUI

struct MainWindow: View {
    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        GeometryReader { geometry in
            HSplitView {
                BrowserContainer()
                    .environmentObject(coordinator.browserManager)
                    .environmentObject(coordinator.bridgeService)
                    .frame(minWidth: 400)

                TerminalContainer()
                    .environmentObject(coordinator.terminalManager)
                    .environmentObject(coordinator.bridgeService)
                    .frame(minWidth: 300)
            }
            .onReceive(NotificationCenter.default.publisher(for: .resetSplitView)) { _ in
                coordinator.splitRatio = 0.6
            }
        }
        .background(Color(NSColor.windowBackgroundColor))
    }
}

extension Notification.Name {
    static let resetSplitView = Notification.Name("resetSplitView")
}