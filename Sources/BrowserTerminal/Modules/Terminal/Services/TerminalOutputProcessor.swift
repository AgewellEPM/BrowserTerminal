import Foundation

class TerminalOutputProcessor {
    private var outputBuffer = Data()
    private let bufferQueue = DispatchQueue(label: "terminal.buffer", qos: .userInteractive)
    private let ansiParser = ANSIParser()

    func processData(_ data: Data, completion: @escaping (String) -> Void) {
        bufferQueue.async { [weak self] in
            guard let self = self else { return }

            // Try to convert data directly first
            if let string = String(data: data, encoding: .utf8) {
                let cleanString = self.cleanANSISequences(string)
                completion(cleanString)
            } else {
                // If direct conversion fails, buffer it
                self.outputBuffer.append(data)

                // Try to process buffered data
                if let string = String(data: self.outputBuffer, encoding: .utf8) {
                    let cleanString = self.cleanANSISequences(string)
                    completion(cleanString)
                    self.outputBuffer.removeAll()
                }
            }
        }
    }

    private func cleanANSISequences(_ input: String) -> String {
        let codes = ansiParser.parse(input)
        var result = ""

        for code in codes {
            switch code {
            case .text(let text):
                result += text
            case .lineFeed:
                result += "\n"
            case .carriageReturn:
                result += "\r"
            case .tab:
                result += "\t"
            case .backspace:
                // Handle backspace by removing last character
                if !result.isEmpty {
                    result.removeLast()
                }
            default:
                // Ignore other control codes for now
                break
            }
        }

        return result
    }
}