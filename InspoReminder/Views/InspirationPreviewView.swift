import SwiftUI

struct InspirationPreviewView: View {
    let inspiration: Inspiration
    
    var body: some View {
        Group {
            switch inspiration.type {
            case .image:
                if let data = Data(base64Encoded: inspiration.content),
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipped()
                }
            case .text:
                Text(inspiration.content)
                    .lineLimit(3)
                    .frame(width: 80, height: 80)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
            case .link:
                VStack {
                    Image(systemName: "link")
                        .font(.title)
                    Text(inspiration.content)
                        .lineLimit(1)
                        .font(.caption)
                }
                .frame(width: 80, height: 80)
                .padding(8)
                .background(Color.gray.opacity(0.1))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(4)
    }
}