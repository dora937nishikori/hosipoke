import SwiftUI

struct ItemDetailView: View {
    let item: WishItem
    var onClose: () -> Void
    @Environment(\.dismiss) private var dismiss

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

                VStack(alignment: .leading, spacing: 8) {
                    Text(item.note)
                        .font(.body)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(UIColor.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    Text(item.createdAt.formatted(date: .complete, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)

                Spacer(minLength: 80)
            }
            .padding(.top, 20)
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
