import SwiftUI

struct TerminalView: View {
    @ObservedObject var session: TerminalSession
    @EnvironmentObject var bridgeService: BridgeService

    var body: some View {
        // Prefer SwiftTerm if available at build time; fall back to custom view
        Group {
            #if canImport(SwiftTerm)
            SwiftTermView()
            #else
            TerminalTextView(session: session)
            #endif
        }
        .background(Color.black)
        .foregroundColor(Color.white)
    }
}
