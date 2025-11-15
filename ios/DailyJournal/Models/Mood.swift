import Foundation

enum Mood: String, CaseIterable, Codable, Identifiable {
    case joyful
    case peaceful
    case grateful
    case neutral
    case tired
    case gloomy

    var id: String { rawValue }

    var title: String {
        switch self {
        case .joyful: return "愉悦"
        case .peaceful: return "平静"
        case .grateful: return "感恩"
        case .neutral: return "一般"
        case .tired: return "疲惫"
        case .gloomy: return "低落"
        }
    }

    var emoji: String {
        switch self {
        case .joyful: return "😄"
        case .peaceful: return "😊"
        case .grateful: return "🙏"
        case .neutral: return "🙂"
        case .tired: return "😴"
        case .gloomy: return "😔"
        }
    }

    var accentColorName: String {
        switch self {
        case .joyful: return "MoodJoyful"
        case .peaceful: return "MoodPeaceful"
        case .grateful: return "MoodGrateful"
        case .neutral: return "MoodNeutral"
        case .tired: return "MoodTired"
        case .gloomy: return "MoodGloomy"
        }
    }
}
