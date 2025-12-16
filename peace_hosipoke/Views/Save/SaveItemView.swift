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

            // 画面幅を「等分」して、1列=1項目の幅を作る（星もラベルもこの幅で揃う）
            let totalWidth = max(0, geo.size.width - 2 * horizontalPadding)
            let slotWidth = totalWidth / CGFloat(options.count)

            VStack(spacing: 10) {
                ZStack(alignment: .top) {

                    // 線は「最初の星中心」〜「最後の星中心」までにしたいので
                    // 左右を slotWidth/2 だけインセットする
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)
                        .cornerRadius(2)
                        .padding(.horizontal, slotWidth / 2)
                        // 星の中心（starSize/2）に線を合わせる
                        .offset(y: starSize / 2 - 2)

                    HStack(spacing: 0) {
                        ForEach(options, id: \.self) { option in
                            VStack(spacing: 6) {
                                starButton(option: option, starSize: starSize)
                                    .frame(width: starSize, height: starSize)

                                Text(option.label)
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(option.color)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.75)     // 端末が狭い時の保険
                                    .allowsTightening(true)       // 文字詰め許可
                            }
                            .frame(width: slotWidth, alignment: .top)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, horizontalPadding)
            .frame(width: geo.size.width, alignment: .top)
        }
        .frame(height: 120)
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
                    .shadow(color: option.color.opacity(isSelected ? 0.4 : 0.0),
                            radius: isSelected ? 6 : 0, y: 2)

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

