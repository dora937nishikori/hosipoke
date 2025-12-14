import SwiftUI

enum AppRoute: Hashable {
    case save(CapturedPhoto)
    case detail(WishItem)
}

struct ContentView: View {
    @StateObject private var store = PocketStore()
    @State private var navigationPath: [AppRoute] = []
    @State private var showCamera = false

    var body: some View {
        NavigationStack(path: $navigationPath) {
            PocketView(
                items: store.items,
                onSelect: { item in navigationPath.append(.detail(item)) },
                onAdd: { showCamera = true }
            )
            .navigationTitle("ポケット")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .save(let photo):
                    SaveItemView(
                        photo: photo.image,
                        onSave: { memo, priority in
                            store.add(photo: photo.image, note: memo, priority: priority)
                            navigationPath.removeAll()
                        },
                        onClose: { navigationPath.removeAll() },
                        onRetake: { showCamera = true }
                    )
                case .detail(let item):
                    ItemDetailView(item: item) {
                        navigationPath.removeLast()
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraPickerView(
                onImagePicked: { image in
                    let captured = CapturedPhoto(image: image)
                    navigationPath.append(.save(captured))
                    showCamera = false
                },
                onCancel: { showCamera = false }
            )
            .ignoresSafeArea()
        }
        .onAppear {
            if store.items.isEmpty { showCamera = true }
        }
    }
}

#Preview { ContentView() }
