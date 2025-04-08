import SwiftUI
import PhotosUI

struct InspirationInputView: View {
    @Binding var inspirations: [Inspiration]
    @State private var showingImagePicker = false
    @State private var newText = ""
    @State private var newLink = ""
    
    var body: some View {
        Section(header: Text("Inspirations")) {
            HStack {
                TextField("Add text inspiration", text: $newText)
                Button("Add") {
                    if !newText.isEmpty {
                        inspirations.append(Inspiration(type: .text, content: newText))
                        newText = ""
                    }
                }
            }
            
            HStack {
                TextField("Add link inspiration", text: $newLink)
                Button("Add") {
                    if !newLink.isEmpty {
                        inspirations.append(Inspiration(type: .link, content: newLink))
                        newLink = ""
                    }
                }
            }
            
            Button("Add Image") {
                showingImagePicker = true
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(inspirations: $inspirations)
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var inspirations: [Inspiration]
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    if let image = image as? UIImage,
                       let data = image.jpegData(compressionQuality: 0.8),
                       let base64String = data.base64EncodedString().nilIfEmpty {
                        DispatchQueue.main.async {
                            self.parent.inspirations.append(Inspiration(type: .image, content: base64String))
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