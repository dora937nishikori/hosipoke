import SwiftUI
import UIKit

struct CameraPickerView: UIViewControllerRepresentable {
    var onImagePicked: (UIImage) -> Void
    var onCancel: () -> Void

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = false

        let canUseCamera = UIImagePickerController.isSourceTypeAvailable(.camera)
        if canUseCamera {
            picker.sourceType = .camera
            picker.cameraCaptureMode = .photo
            picker.showsCameraControls = false
            picker.cameraOverlayView = context.coordinator.makeOverlay(in: picker)
            context.coordinator.picker = picker
        } else {
            // カメラ非対応時はライブラリにフォールバックし、オーバーレイを外す
            picker.sourceType = .photoLibrary
            picker.showsCameraControls = true
            picker.cameraOverlayView = nil
            context.coordinator.picker = nil
        }
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraPickerView
        weak var picker: UIImagePickerController?

        init(parent: CameraPickerView) { self.parent = parent }

        func makeOverlay(in picker: UIImagePickerController) -> UIView {
            let overlay = CameraOverlayView(frame: picker.view.bounds)
            overlay.onShutter = { [weak self] in
                self?.picker?.takePicture()
            }
            overlay.onPocket = { [weak self] in
                self?.parent.onCancel()
            }
            return overlay
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onCancel()
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImagePicked(image)
            } else {
                parent.onCancel()
            }
        }
    }
}

// Overlay UIView to mimic provided design
final class CameraOverlayView: UIView {
    var onShutter: (() -> Void)?
    var onPocket: (() -> Void)?

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = UIColor(red: 0.63, green: 0.36, blue: 0.15, alpha: 1.0)
        return label
    }()

    private let shutterButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .yellow
        button.layer.cornerRadius = 36
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 6
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        let star = UIImage(systemName: "star.fill")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 26, weight: .bold))
        button.setImage(star, for: .normal)
        button.tintColor = .black
        return button
    }()

    private let pocketButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "ポケット"
        config.image = UIImage(systemName: "bag")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .regular))
        config.imagePadding = 6
        config.baseForegroundColor = .black
        let button = UIButton(configuration: config)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        backgroundColor = .clear
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        let topBar = UIView()
        topBar.backgroundColor = .yellow

        let bottomBar = UIView()
        bottomBar.backgroundColor = .yellow

        let leftCircle = UIView()
        leftCircle.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        leftCircle.layer.cornerRadius = 26
        leftCircle.layer.borderColor = UIColor(white: 0.85, alpha: 1.0).cgColor
        leftCircle.layer.borderWidth = 1

        dateLabel.text = Self.dateString(Date())

        [topBar, bottomBar, dateLabel, leftCircle, shutterButton, pocketButton].forEach { addSubview($0) }
        [topBar, bottomBar, dateLabel, leftCircle, shutterButton, pocketButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: topAnchor),
            topBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            topBar.heightAnchor.constraint(equalToConstant: 110),

            bottomBar.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 130),

            leftCircle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            leftCircle.bottomAnchor.constraint(equalTo: bottomBar.bottomAnchor, constant: -34),
            leftCircle.widthAnchor.constraint(equalToConstant: 52),
            leftCircle.heightAnchor.constraint(equalToConstant: 52),

            shutterButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            shutterButton.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),
            shutterButton.widthAnchor.constraint(equalToConstant: 72),
            shutterButton.heightAnchor.constraint(equalToConstant: 72),

            pocketButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -28),
            pocketButton.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),

            dateLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            dateLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -170)
        ])

        shutterButton.addTarget(self, action: #selector(shutterTapped), for: .touchUpInside)
        pocketButton.addTarget(self, action: #selector(pocketTapped), for: .touchUpInside)
    }

    @objc private func shutterTapped() { onShutter?() }
    @objc private func pocketTapped() { onPocket?() }

    private static func dateString(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy.M.dd"
        return df.string(from: date)
    }
}
