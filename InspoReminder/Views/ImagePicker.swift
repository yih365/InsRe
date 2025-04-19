import SwiftUI
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var inspirations: [Inspiration]
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 0
        config.filter = .images
        config.selection = .ordered
        config.preferredAssetRepresentationMode = .current
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // No update needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        var pendingResults: [PHPickerResult] = []
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            defer {
                DispatchQueue.main.async {
                    self.parent.dismiss()
                }
            }
            
            guard !results.isEmpty else { return }
            
            // Process selected images
            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { image, _ in
                        if let image = image as? UIImage,
                           let data = image.jpegData(compressionQuality: 0.8),
                           let base64String = data.base64EncodedString().nilIfEmpty {
                            DispatchQueue.main.async {
                                self.parent.inspirations.append(
                                    Inspiration(type: .image, content: base64String)
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}

extension String {
    var nilIfEmpty: String? {
        self.isEmpty ? nil : self
    }
}