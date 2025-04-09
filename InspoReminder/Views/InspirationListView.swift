import SwiftUI

struct InspirationListView: View {
    let inspirations: [Inspiration]
    let onDelete: (Inspiration) -> Void
    let squareSize: CGFloat?
    
    init(inspirations: [Inspiration], onDelete: @escaping (Inspiration) -> Void, squareSize: CGFloat? = nil) {
        self.inspirations = inspirations
        self.onDelete = onDelete
        self.squareSize = squareSize
    }
    
    var body: some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible())]
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(inspirations) { inspiration in
                InspirationCell(inspiration: inspiration, squareSize: squareSize!, onDelete: onDelete)
            }
        }
        .frame(minHeight: CGFloat(ceil(Double(inspirations.count) / 2.0)) * ((squareSize ?? 0) + 60))
    }
}

private struct InspirationCell: View {
    let inspiration: Inspiration
    let squareSize: CGFloat?
    let onDelete: (Inspiration) -> Void
    
    init(inspiration: Inspiration, squareSize: CGFloat? = nil, onDelete: @escaping (Inspiration) -> Void) {
        self.inspiration = inspiration
        self.squareSize = squareSize
        self.onDelete = onDelete
    }
    
    var body: some View {
        VStack {
            switch inspiration.type {
            case .text:
                Text(inspiration.content)
                    .frame(width: squareSize, height: squareSize)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
            case .link:
                Link(inspiration.content, destination: URL(string: inspiration.content) ?? URL(string: "https://apple.com")!)
                    .frame(width: squareSize, height: squareSize)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(15)
            case .image:
                if let data = Data(base64Encoded: inspiration.content),
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: squareSize, height: squareSize)
                        .clipped()
                        .cornerRadius(15)
                }
            }
            
            Button(action: { onDelete(inspiration) }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
    }
}