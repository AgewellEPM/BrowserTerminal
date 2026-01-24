import AppKit

class TerminalScrollViewFactory {
    static func create(for session: TerminalSession, coordinator: TerminalTextViewCoordinator) -> NSScrollView {
        let scrollView = NSScrollView()
        let textView = CustomTerminalTextView()

        // Configure text view
        textView.isEditable = false  // Terminal text is not directly editable
        textView.isSelectable = true
        textView.isRichText = false  // Use plain text for terminal
        textView.importsGraphics = false
        textView.allowsUndo = false
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.textContainer?.containerSize = CGSize(width: scrollView.frame.width, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true
        textView.backgroundColor = NSColor.black
        textView.textColor = NSColor.white
        textView.font = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        textView.delegate = coordinator

        // Store reference
        coordinator.textView = textView
        textView.inputHandler = coordinator.inputHandler

        // Set up scroll view
        scrollView.documentView = textView
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = false
        scrollView.borderType = .noBorder
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        return scrollView
    }
}