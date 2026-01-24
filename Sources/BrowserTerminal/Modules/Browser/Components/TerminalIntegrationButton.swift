import SwiftUI

struct TerminalIntegrationButton: View {
    var body: some View {
        Menu {
            Button("Send Page URL to Terminal") {
                NotificationCenter.default.post(
                    name: .sendURLToTerminal,
                    object: nil
                )
            }
            Button("Copy Terminal Output") {
                NotificationCenter.default.post(
                    name: .copyTerminalOutput,
                    object: nil
                )
            }
        } label: {
            Image(systemName: "terminal")
        }
        .menuStyle(BorderlessButtonMenuStyle())
    }
}

extension Notification.Name {
    static let sendURLToTerminal = Notification.Name("sendURLToTerminal")
    static let copyTerminalOutput = Notification.Name("copyTerminalOutput")
}