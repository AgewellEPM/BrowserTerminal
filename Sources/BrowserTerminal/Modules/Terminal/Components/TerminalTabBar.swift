import SwiftUI

struct TerminalTabBar: View {
    @EnvironmentObject var terminalManager: TerminalManager

    var body: some View {
        HStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 2) {
                    ForEach(terminalManager.sessions) { session in
                        TerminalTab(session: session)
                            .environmentObject(terminalManager)
                    }
                }
                .padding(.horizontal, 4)
            }

            Button(action: {
                terminalManager.addSession()
            }) {
                Image(systemName: "plus.circle")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 8)
        }
        .frame(height: 32)
        .background(Color(NSColor.controlBackgroundColor))
    }
}

struct TerminalTab: View {
    let session: TerminalSession
    @EnvironmentObject var terminalManager: TerminalManager

    var isActive: Bool {
        terminalManager.activeSessionId == session.id
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: session.isRunning ? "terminal.fill" : "terminal")
                .font(.system(size: 12))

            Text(session.title)
                .font(.system(size: 12))
                .lineLimit(1)

            if terminalManager.sessions.count > 1 {
                Button(action: {
                    terminalManager.removeSession(id: session.id)
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10))
                }
                .buttonStyle(PlainButtonStyle())
                .opacity(isActive ? 1 : 0.5)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(isActive ? Color.accentColor.opacity(0.2) : Color.clear)
        .cornerRadius(4)
        .onTapGesture {
            terminalManager.activeSessionId = session.id
        }
    }
}