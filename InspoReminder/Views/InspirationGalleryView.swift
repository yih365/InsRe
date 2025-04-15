import SwiftUI
import SwiftData

struct InspirationGalleryView: View {
    @Query private var goals: [Goal]
    @State private var inspirationViewMode: ViewMode = .grid
    
    private var allInspirations: [Inspiration] {
        goals.flatMap { $0.inspirations }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Picker("View Mode", selection: $inspirationViewMode) {
                        Image(systemName: "square.grid.2x2").tag(ViewMode.grid)
                        Image(systemName: "list.bullet").tag(ViewMode.list)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    .frame(width: 200)
                    
                    switch inspirationViewMode {
                    case .grid:
                        InspirationListView(
                            inspirations: allInspirations,
                            onDelete: { _ in },
                            onFavorite: { inspiration in
                                inspiration.isFavorite.toggle()
                            }
                        )
                        .frame(height: CGFloat(ceil(Double(allInspirations.count) / 2.0)) * 200)
                        .padding(.horizontal)
                    case .list:
                        VStack(spacing: 20) {
                            InspirationCarouselView(
                                inspirations: allInspirations,
                                title: "Images",
                                onDelete: { _ in },
                                onFavorite: { inspiration in
                                    inspiration.isFavorite.toggle()
                                }
                            )
                            
                            InspirationCarouselView(
                                inspirations: allInspirations,
                                title: "Text",
                                onDelete: { _ in },
                                onFavorite: { inspiration in
                                    inspiration.isFavorite.toggle()
                                }
                            )
                            
                            InspirationCarouselView(
                                inspirations: allInspirations,
                                title: "Links",
                                onDelete: { _ in },
                                onFavorite: { inspiration in
                                    inspiration.isFavorite.toggle()
                                }
                            )
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Inspiration Gallery")
        }
    }
}