import SwiftUI
import UIKit

struct SaveItemView: View {
    let photo: UIImage
    var onSave: (String, WishPriority) -> Void
    var onClose: () -> Void
    var onRetake: () -> Void

    @State private var memo: String = ""
    @State private var priority: WishPriority = .none
    @Environment(\.dismiss) private var dismiss

    private var previewImage: Image { Image(uiImage: photo) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                previewImage
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .background(Color(UIColor.systemGray5))
                    .padding(.horizontal, 16)

                VStack(alignment: .leading, spacing: 12) {
                    Text("いつほしい？")
                        .font(.headline)
                        .padding(.horizontal, 16)

                    PriorityPicker(selected: $priority)
                        .padding(.horizontal, 12)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("メモ")
                        .font(.headline)
                        .padding(.horizontal, 16)
                    TextField("アイテムに関するメモを入力", text: $memo, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal, 16)
                }

                Button {
                    onSave(memo, priority)
                } label: {
                    Text("アイテムを保存する")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.yellow)
                        .foregroundColor(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .padding(.top, 16)
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("アイテムを保存")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { onClose(); dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("撮り直す") { onRetake() }
            }
        }
    }
}

struct PriorityPicker: View {
    @Binding var selected: WishPriority

    private let options: [WishPriority] = [.now, .soon, .later, .reward, .someday]
    @State private var sparkling: WishPriority?

    var body: some View {
        GeometryReader { geo in
            let starSize: CGFloat = 32
            let horizontalPadding: CGFloat = 16
            let gridWidth = max(starSize * CGFloat(options.count), geo.size.width - 2 * horizontalPadding)
            let spacing = max(0, (gridWidth - starSize * CGFloat(options.count)) / CGFloat(options.count - 1))
            let lineWidth = max(0, gridWidth - starSize)

            VStack(spacing: 10) {
                ZStack(alignment: .center) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: lineWidth, height: 4)
                        .cornerRadius(2)

                    HStack(spacing: spacing) {
                        ForEach(options, id: \.self) { option in
                            starButton(option: option, starSize: starSize)
                                .frame(width: starSize, height: starSize)
                        }
                    }
                    .frame(width: gridWidth)
                }
                .frame(maxWidth: .infinity)

                HStack(spacing: spacing) {
                    ForEach(options, id: \.self) { option in
                        Text(option.label)
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundStyle(option.color)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                            .frame(width: starSize + spacing, alignment: .center)
                    }
                }
                .frame(width: gridWidth)
            }
            .padding(.horizontal, horizontalPadding)
            .frame(width: max(0, geo.size.width), alignment: .top)
        }
        .frame(height: 130)
    }

    private func starButton(option: WishPriority, starSize: CGFloat) -> some View {
        let isSelected = selected == option
        let isSparkling = sparkling == option

        return Button {
            selected = option
            withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                sparkling = option
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeOut(duration: 0.2)) {
                    sparkling = nil
                }
            }
        } label: {
            ZStack {
                Image(systemName: "star.fill")
                    .font(.system(size: starSize, weight: .bold))
                    .foregroundStyle(option.color)
                    .scaleEffect(isSelected ? 1.15 : 1.0)
                    .shadow(color: option.color.opacity(isSelected ? 0.4 : 0.0), radius: isSelected ? 6 : 0, y: 2)

                if isSparkling {
                    Image(systemName: "sparkles")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(option.color)
                        .scaleEffect(1.2)
                        .opacity(0.9)
                        .offset(y: -20)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .buttonStyle(.plain)
    }
}
