import Foundation
import Combine

class TerminalManager: ObservableObject {
    @Published var sessions: [TerminalSession] = []
    @Published var activeSessionId: UUID?

    private var cancellables = Set<AnyCancellable>()

    init() {
        addSession()
        setupNotifications()
    }

    private func setupNotifications() {
        NotificationCenter.default.publisher(for: .newTerminalTab)
            .sink { [weak self] _ in
                self?.addSession()
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: .clearTerminal)
            .sink { [weak self] _ in
                self?.clearActiveSession()
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: .resetTerminal)
            .sink { [weak self] _ in
                self?.resetActiveSession()
            }
            .store(in: &cancellables)
    }

    func addSession() {
        let session = TerminalSession()
        sessions.append(session)
        activeSessionId = session.id
    }

    func removeSession(id: UUID) {
        sessions.removeAll { $0.id == id }
        if sessions.isEmpty {
            addSession()
        } else if activeSessionId == id {
            activeSessionId = sessions.first?.id
        }
    }

    func clearActiveSession() {
        guard let id = activeSessionId,
              let session = sessions.first(where: { $0.id == id }) else { return }
        session.clear()
    }

    func resetActiveSession() {
        guard let id = activeSessionId,
              let index = sessions.firstIndex(where: { $0.id == id }) else { return }

        let newSession = TerminalSession()
        sessions[index].terminate()
        sessions[index] = newSession
        activeSessionId = newSession.id
    }

    func writeToActiveSession(_ text: String) {
        guard let id = activeSessionId,
              let session = sessions.first(where: { $0.id == id }) else { return }
        session.write(text)
    }

    func cleanup() {
        for session in sessions {
            session.terminate()
        }
    }
}