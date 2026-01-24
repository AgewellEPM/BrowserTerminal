import Foundation

enum IDEChoice: String, Codable, CaseIterable {
    case xcode = "Xcode"
    case claudeCode = "Claude Code"

    var commandName: String {
        switch self {
        case .xcode:
            return "xed"
        case .claudeCode:
            return "claude"
        }
    }

    var displayName: String {
        return rawValue
    }
}

class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @Published var preferredIDE: IDEChoice {
        didSet {
            UserDefaults.standard.set(preferredIDE.rawValue, forKey: "preferredIDE")
        }
    }

    @Published var alwaysOnTop: Bool {
        didSet {
            UserDefaults.standard.set(alwaysOnTop, forKey: "alwaysOnTop")
        }
    }

    @Published var fontSize: Double {
        didSet {
            UserDefaults.standard.set(fontSize, forKey: "fontSize")
        }
    }

    private init() {
        // Load saved preferences
        if let ideString = UserDefaults.standard.string(forKey: "preferredIDE"),
           let ide = IDEChoice(rawValue: ideString) {
            self.preferredIDE = ide
        } else {
            self.preferredIDE = .claudeCode // Default to Claude Code
        }

        self.alwaysOnTop = UserDefaults.standard.bool(forKey: "alwaysOnTop")
        self.fontSize = UserDefaults.standard.double(forKey: "fontSize")
        if fontSize == 0 {
            fontSize = 13 // Default font size
        }
    }

    func reset() {
        preferredIDE = .claudeCode
        alwaysOnTop = false
        fontSize = 13
    }
}