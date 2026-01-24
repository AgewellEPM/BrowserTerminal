import Foundation

class ControlCharacterMapper {
    static func map(_ char: Character) -> String? {
        switch char {
        case "a": return "\u{0001}"
        case "b": return "\u{0002}"
        case "c": return "\u{0003}"
        case "d": return "\u{0004}"
        case "e": return "\u{0005}"
        case "f": return "\u{0006}"
        case "g": return "\u{0007}"
        case "h": return "\u{0008}"
        case "i": return "\u{0009}"
        case "j": return "\u{000A}"
        case "k": return "\u{000B}"
        case "l": return "\u{000C}"
        case "m": return "\u{000D}"
        case "n": return "\u{000E}"
        case "o": return "\u{000F}"
        case "p": return "\u{0010}"
        case "q": return "\u{0011}"
        case "r": return "\u{0012}"
        case "s": return "\u{0013}"
        case "t": return "\u{0014}"
        case "u": return "\u{0015}"
        case "v": return "\u{0016}"
        case "w": return "\u{0017}"
        case "x": return "\u{0018}"
        case "y": return "\u{0019}"
        case "z": return "\u{001A}"
        default: return nil
        }
    }
}