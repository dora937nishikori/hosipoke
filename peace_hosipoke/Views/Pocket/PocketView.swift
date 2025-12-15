import SwiftUI

struct PocketView: View {
    let items: [WishItem]
    let onSelect: (WishItem) -> Void
    let onAdd: () -> Void

    private let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]

    var body: some View {
        GeometryReader { geo in
            let cardWidth = max(0, (geo.size.width - 16 * 2 - 16) / 2)
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        if items.isEmpty {
                            let ratios: [CGFloat] = [1.2, 1.0, 1.1, 0.9]
                            ForEach(Array(ratios.enumerated()), id: \.offset) { idx, ratio in
                                PlaceholderCard(ratio: ratio, cardWidth: cardWidth)
                                    .padding(.top, idx % 2 == 1 ? 12 : 0)
                            }
                        } else {
                            ForEach(Array(items.enumerated()), id: \.element.id) { idx, item in
                                let column = idx % 2
                                Button {
                                    onSelect(item)
                                } label: {
                                    ItemCard(item: item, cardWidth: cardWidth)
                                }
                                .padding(.top, column == 1 ? 12 : 0)
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                    .padding(.bottom, 120) // space for floating button
                }

                Button(action: onAdd) {
                    VStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .bold))
                        Text("あつめる")
                            .font(.footnote)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.black)
                    .frame(width: 96, height: 96)
                    .background(Color.yellow)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.15), radius: 8, y: 6)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 24)
            }
        }
    }
}

struct PlaceholderCard: View {
    let ratio: CGFloat
    let cardWidth: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(Color(UIColor.systemGray5))
            .frame(width: max(0, cardWidth), height: max(0, cardWidth * ratio))
    }
}

struct ItemCard: View {
    let item: WishItem
    let cardWidth: CGFloat

    private var aspectRatio: CGFloat {
        if let size = item.image?.size, size.width > 0 {
            return max(0.7, min(size.height / size.width, 1.8))
        }
        return 1.2
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            item.thumbnail
                .resizable()
                .scaledToFill()
                .frame(width: max(0, cardWidth), height: max(0, cardWidth * aspectRatio))
                .clipped()
                .background(Color(UIColor.systemGray5))
                .clipShape(RoundedRectangle(cornerRadius: 18))

            if item.priority != .none {
                Text(item.priority.label)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(item.priority.color.opacity(0.9))
                    .clipShape(Capsule())
                    .padding(10)
            }
        }
    }
}
