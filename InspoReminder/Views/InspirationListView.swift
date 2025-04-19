import SwiftUI

struct InspirationCell: View {
    let inspiration: Inspiration
    let squareSize: CGFloat?
    let onDelete: (Inspiration) -> Void
    let onFavorite: (Inspiration) -> Void
    @State private var showingDetail = false
    
    var body: some View {
        VStack {
            ZStack {
                switch inspiration.type {
                case .text:
                    Text(inspiration.content)
                        .lineLimit(6)
                        .frame(width: squareSize, height: squareSize)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(15)
                        .onTapGesture {
                            showingDetail = true
                        }
                        .sheet(isPresented: $showingDetail) {
                            NavigationView {
                                ScrollView {
                                    Text(inspiration.content)
                                        .padding()
                                }
                                .navigationTitle("Text Inspiration")
                                .navigationBarItems(trailing: Button("Done") {
                                    showingDetail = false
                                })
                            }
                        }
                case .link:
                    if let url = URL(string: inspiration.content),
                       UIApplication.shared.canOpenURL(url) {
                        Link(destination: url) {
                            Text(url.host ?? inspiration.content)
                                .lineLimit(2)
                                .frame(width: squareSize, height: squareSize)
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(15)
                        }
                    } else {
                        Text("Invalid URL")
                            .frame(width: squareSize, height: squareSize)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(15)
                    }
                case .image:
                    if let data = Data(base64Encoded: inspiration.content),
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: squareSize, height: squareSize)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(15)
                            .onTapGesture {
                                showingDetail = true
                            }
                            .sheet(isPresented: $showingDetail) {
                                NavigationView {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                        .navigationTitle("Image Inspiration")
                                        .navigationBarItems(trailing: Button("Done") {
                                            showingDetail = false
                                        })
                                }
                            }
                    }
                }
            }
            .frame(width: squareSize, height: squareSize)
            .padding(.bottom, 18)
            
            HStack {
                Button(action: { onDelete(inspiration) }) {
                    Image(systemName: "trash")
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: { onFavorite(inspiration) }) {
                    Image(systemName: inspiration.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 5)
        }
    }
}

struct InspirationListView: View {
    let inspirations: [Inspiration]
    let onDelete: (Inspiration) -> Void
    let onFavorite: (Inspiration) -> Void
    let squareSize: CGFloat = 150
    
    var sortedInspirations: [Inspiration] {
        inspirations.sorted { first, second in
            if first.isFavorite && !second.isFavorite {
                return true
            } else if !first.isFavorite && second.isFavorite {
                return false
            }
            return false
        }
    }
    
    var body: some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible())]
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(sortedInspirations) { inspiration in
                InspirationCell(
                    inspiration: inspiration,
                    squareSize: squareSize,
                    onDelete: onDelete,
                    onFavorite: { inspiration in
                        if let index = inspirations.firstIndex(where: { $0.id == inspiration.id }) {
                            inspirations[index].isFavorite.toggle()
                        }
                    }
                )
            }
        }
        .frame(minHeight: getListHeight())
    }
    
    private func getListHeight() -> CGFloat {
        let rows = CGFloat(ceil(Double(inspirations.count) / 2.0))
        let height = rows * (squareSize + 60)
        return height
    }
}

