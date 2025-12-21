import SwiftUI

struct ItemDetailView: View {
    let item: WishItem
    var onSave: (String, WishPriority) -> Void
    var onClose: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var memo: String = ""
    @State private var priority: WishPriority = .none

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                item.thumbnail
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .background(Color(UIColor.systemGray5))
                    .padding(.horizontal, 16)

                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("いつほしい？")
                            .font(.headline)
                        PriorityPicker(selected: $priority)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("メモ")
                            .font(.headline)
                        TextField("アイテムに関するメモを入力", text: $memo, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                    }

                    Button {
                        onSave(memo, priority)
                        dismiss()
                    } label: {
                        Text("更新する")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.yellow)
                            .foregroundColor(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(.horizontal, 16)

                Text(item.createdAt.formatted(date: .complete, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer(minLength: 80)
            }
            .padding(.top, 20)
        }
        .onAppear {
            memo = item.note
            priority = item.priority
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("アイテム詳細")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { onClose(); dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                }
            }
        }
    }
}
