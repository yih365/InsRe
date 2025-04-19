import SwiftUI

struct InspirationCarouselView: View {
    let inspirations: [Inspiration]
    let title: String
    let onDelete: (Inspiration) -> Void
    let onFavorite: (Inspiration) -> Void
    
    var filteredInspirations: [Inspiration] {
        switch title {
        case "Images":
            return inspirations.filter { $0.type == .image }
        case "Text":
            return inspirations.filter { $0.type == .text }
        case "Links":
            return inspirations.filter { $0.type == .link }
        default:
            return []
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {  // Added spacing parameter
            if !filteredInspirations.isEmpty {
                Text(title)
                    .font(.headline)
                    .padding(.horizontal)
                
                Divider()
                    .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 20) {
                        ForEach(filteredInspirations) { inspiration in
                            VStack {
                                InspirationCell(
                                    inspiration: inspiration,
                                    squareSize: 150,
                                    onDelete: onDelete,
                                    onFavorite: { inspiration in
                                        if let index = inspirations.firstIndex(where: { $0.id == inspiration.id }) {
                                            inspirations[index].isFavorite.toggle()
                                        }
                                    }
                                )
                            }
                            .frame(width: 180)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 200)
                .background(Color.white)
                .overlay(
                    HStack {
                        LinearGradient(
                            gradient: Gradient(colors: [Color(UIColor.systemBackground), .clear]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: 30)
                        Spacer()
                        LinearGradient(
                            gradient: Gradient(colors: [.clear, Color(UIColor.systemBackground)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: 30)
                    }
                )
                
                Divider()
                    .padding(.horizontal)
                .background(Color.gray.opacity(0.1))
            }
        }
    }
}
