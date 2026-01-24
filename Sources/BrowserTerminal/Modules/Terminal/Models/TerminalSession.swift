import Foundation
import Combine

class TerminalSession: ObservableObject, Identifiable {
    let id = UUID()
    @Published var title: String = "Terminal"
    @Published var output: String = ""
    @Published var isRunning: Bool = false

    private var ptyController: PTYController?
    private var outputProcessor: TerminalOutputProcessor

    init() {
        self.outputProcessor = TerminalOutputProcessor()
        startSession()
    }

    func startSession() {
        ptyController = PTYController()
        ptyController?.delegate = self
        ptyController?.start()
        isRunning = true

        // Send initial message
        output = "BrowserTerminal - macOS Terminal Emulator\n"
        output += "Starting shell session...\n\n"
    }

    func write(_ text: String) {
        guard let data = text.data(using: .utf8) else { return }
        ptyController?.write(data)
    }

    func clear() {
        DispatchQueue.main.async {
            self.output = ""
        }
        // Send clear screen escape sequence
        write("\u{001B}[2J\u{001B}[H")
    }

    func terminate() {
        ptyController?.stop()
        isRunning = false
    }

    func resize(rows: Int, cols: Int) {
        ptyController?.resize(rows: rows, cols: cols)
    }

    deinit {
        terminate()
    }
}

extension TerminalSession: PTYControllerDelegate {
    func ptyController(_ controller: PTYController, didReceiveData data: Data) {
        outputProcessor.processData(data) { [weak self] processedString in
            DispatchQueue.main.async {
                self?.output += processedString
                // Keep output size reasonable
                if let output = self?.output, output.count > 10000 {
                    self?.output = String(output.suffix(8000))
                }
            }
        }
    }

    func ptyControllerDidTerminate(_ controller: PTYController) {
        DispatchQueue.main.async {
            self.isRunning = false
            self.output += "\n[Process terminated]\n"
        }
    }
}
