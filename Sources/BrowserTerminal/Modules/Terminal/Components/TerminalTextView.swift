import SwiftUI
import AppKit

struct TerminalTextView: NSViewRepresentable {
    @ObservedObject var session: TerminalSession

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = TerminalScrollViewFactory.create(for: session, coordinator: context.coordinator)
        context.coordinator.session = session
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? CustomTerminalTextView else { return }

        if session.output != context.coordinator.lastOutput {
            context.coordinator.updateTerminalOutput(session.output)
            DispatchQueue.main.async {
                textView.scrollToEndOfDocument(nil)
            }
        }

        // Update PTY size based on view metrics
        let font = textView.font ?? NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        let lineHeight = textView.layoutManager?.defaultLineHeight(for: font) ?? (font.pointSize * 1.4)
        let charWidth = "W".size(withAttributes: [.font: font]).width
        let contentSize = scrollView.contentView.bounds.size
        let cols = max(20, Int(floor(contentSize.width / max(charWidth, 1))))
        let rows = max(5, Int(floor(contentSize.height / max(lineHeight, 1))))

        if context.coordinator.lastCols != cols || context.coordinator.lastRows != rows {
            context.coordinator.lastCols = cols
            context.coordinator.lastRows = rows
            session.resize(rows: rows, cols: cols)
        }
    }

    func makeCoordinator() -> TerminalTextViewCoordinator {
        TerminalTextViewCoordinator()
    }
}
