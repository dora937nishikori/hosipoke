import SwiftUI
import UIKit
import Combine

@MainActor
final class PocketStore: ObservableObject {
    @Published private(set) var items: [WishItem] = []

    func add(photo: UIImage, note: String, priority: WishPriority) {
        let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
        let content = trimmed.isEmpty ? "メモなし" : trimmed
        let newItem = WishItem(id: UUID(), note: content, createdAt: Date(), image: photo, priority: priority)
        items.insert(newItem, at: 0)
    }
}
