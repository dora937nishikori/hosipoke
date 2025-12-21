import SwiftUI
import UIKit

enum WishPriority: String, CaseIterable, Hashable {
    case now, soon, later, reward, someday, none

    var label: String {
        switch self {
        case .now: return "すぐほしい"
        case .soon: return "次の機会に"
        case .later: return "考えてから"
        case .reward: return "ごほうびに"
        case .someday: return "いつかの夢"
        case .none: return "なし"
        }
    }

    var color: Color {
        switch self {
        case .now: return Color(red: 1.0, green: 0.35, blue: 0.35)        // red
        case .soon: return Color(red: 1.0, green: 0.70, blue: 0.12)       // orange
        case .later: return Color(red: 0.20, green: 0.75, blue: 0.38)     // green
        case .reward: return Color(red: 0.12, green: 0.78, blue: 0.95)    // cyan
        case .someday: return Color(red: 0.58, green: 0.44, blue: 0.93)   // purple
        case .none: return .gray
        }
    }
}

struct WishItem: Identifiable, Hashable {
    let id: UUID
    var note: String
    var createdAt: Date
    var image: UIImage?
    var priority: WishPriority

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: WishItem, rhs: WishItem) -> Bool {
        lhs.id == rhs.id && lhs.note == rhs.note && lhs.priority == rhs.priority
    }

    var thumbnail: Image {
        if let uiImage = image {
            return Image(uiImage: uiImage)
        }
        return Image(systemName: "photo")
    }
}

struct CapturedPhoto: Hashable {
    let id = UUID()
    let image: UIImage
}
