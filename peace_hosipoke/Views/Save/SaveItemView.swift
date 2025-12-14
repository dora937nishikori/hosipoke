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

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(options, id: \.self) { option in
                    Button {
                        selected = option
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundStyle(option.color)
                            Text(option.label)
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .foregroundStyle(option.color)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 8)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(selected == option ? option.color : Color.clear, lineWidth: 2)
                        )
                        .shadow(color: Color.black.opacity(0.08), radius: 3, y: 1)
                    }
                }
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
        }
    }
}
