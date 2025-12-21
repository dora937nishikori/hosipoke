import SwiftUI

struct PocketView: View {
    let items: [WishItem]
    let onSelect: (WishItem) -> Void
    let onAdd: () -> Void

    var body: some View {
        GeometryReader { geo in
            let horizontalPadding: CGFloat = 16
            let columnSpacing: CGFloat = 16
            let verticalSpacing: CGFloat = 16
            let rightColumnTopOffset: CGFloat = 12
            let cardWidth = max(0, (geo.size.width - horizontalPadding * 2 - columnSpacing) / 2)

            let leftItems = items.enumerated().filter { $0.offset % 2 == 0 }.map { $0.element }
            let rightItems = items.enumerated().filter { $0.offset % 2 == 1 }.map { $0.element }

            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    HStack(alignment: .top, spacing: columnSpacing) {
                        VStack(spacing: verticalSpacing) {
                            if items.isEmpty {
                                PlaceholderColumn(
                                    ratios: [1.2, 1.0, 1.1, 0.9],
                                    cardWidth: cardWidth,
                                    topOffset: 0,
                                    spacing: verticalSpacing
                                )
                            } else {
                                ForEach(leftItems, id: \.id) { item in
                                    Button { onSelect(item) } label: {
                                        ItemCard(item: item, cardWidth: cardWidth)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        VStack(spacing: verticalSpacing) {
                            if items.isEmpty {
                                PlaceholderColumn(
                                    ratios: [1.0, 1.1, 0.95, 1.05],
                                    cardWidth: cardWidth,
                                    topOffset: rightColumnTopOffset,
                                    spacing: verticalSpacing
                                )
                            } else {
                                ForEach(Array(rightItems.enumerated()), id: \.element.id) { idx, item in
                                    Button { onSelect(item) } label: {
                                        ItemCard(item: item, cardWidth: cardWidth)
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.top, idx == 0 ? rightColumnTopOffset : 0)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, horizontalPadding)
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

private struct PlaceholderColumn: View {
    let ratios: [CGFloat]
    let cardWidth: CGFloat
    let topOffset: CGFloat
    let spacing: CGFloat

    var body: some View {
        VStack(spacing: spacing) {
            ForEach(Array(ratios.enumerated()), id: \.offset) { idx, ratio in
                PlaceholderCard(ratio: ratio, cardWidth: cardWidth)
                    .padding(.top, idx == 0 ? topOffset : 0)
            }
        }
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
