import SwiftUI

struct TerminalContainer: View {
    @EnvironmentObject var terminalManager: TerminalManager
    @EnvironmentObject var bridgeService: BridgeService

    var body: some View {
        VStack(spacing: 0) {
            TerminalTabBar()
                .environmentObject(terminalManager)

            if let activeId = terminalManager.activeSessionId,
               let session = terminalManager.sessions.first(where: { $0.id == activeId }) {
                TerminalView(session: session)
                    .environmentObject(bridgeService)
            } else {
                EmptyTerminalView()
            }
        }
    }
}

struct EmptyTerminalView: View {
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "terminal")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No terminal session")
                .font(.headline)
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.9))
    }
}