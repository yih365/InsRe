import SwiftUI
import SwiftData

struct AddGoalView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var motivation = ""
    @State private var category: GoalCategory = .personalDevelopment
    @State private var inspirations: [Inspiration] = []
    @State private var showingTextInput = false
    @State private var showingLinkInput = false
    @State private var showingImageInput = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Title")
                        .font(.headline)
                    TextField("Enter goal title", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Category")
                        .font(.headline)
                    HStack {
                        Picker("Category", selection: $category) {
                            ForEach(GoalCategory.allCases, id: \.self) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        Spacer()
                    }
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Motivation/Reason")
                        .font(.headline)
                    TextField("Why do you want to achieve this?", text: $motivation, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(1...5)
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .center, spacing: 8) {
                        Text("Inspirations")
                            .font(.headline)
                        
                        Menu {
                            Button(action: { showingTextInput = true }) {
                                Label("Add Text", systemImage: "text.quote")
                            }
                            Button(action: { showingLinkInput = true }) {
                                Label("Add Link", systemImage: "link")
                            }
                            Button(action: { showingImageInput = true }) {
                                Label("Add Image", systemImage: "photo")
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    if !inspirations.isEmpty {
                        GeometryReader { geometry in
                            InspirationListView(
                                inspirations: inspirations,
                                onDelete: { inspiration in
                                    if let index = inspirations.firstIndex(where: { $0.id == inspiration.id }) {
                                        inspirations.remove(at: index)
                                    }
                                },
                                onFavorite: { inspiration in
                                    if let index = inspirations.firstIndex(where: { $0.id == inspiration.id }) {
                                        inspirations[index].isFavorite.toggle()
                                    }
                                }
                            )
                        }
                        .frame(height: CGFloat(ceil(Double(inspirations.count) / 2.0)) * 200)
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("New Goal")
        .navigationBarItems(
            trailing: Button("Save") {
                let goal = Goal(title: title, motivation: motivation, category: category)
                goal.inspirations = inspirations
                modelContext.insert(goal)
                dismiss()
            }
                .disabled(title.isEmpty || motivation.isEmpty)
        )
        .sheet(isPresented: $showingTextInput) {
            NavigationView {
                TextInspirationView(inspirations: $inspirations, isPresented: $showingTextInput)
                    .navigationTitle("Add Text")
            }
        }
        .sheet(isPresented: $showingLinkInput) {
            NavigationView {
                LinkInspirationView(inspirations: $inspirations, isPresented: $showingLinkInput)
                    .navigationTitle("Add Link")
            }
        }
        .sheet(isPresented: $showingImageInput) {
            NavigationView {
                ImageInspirationView(inspirations: $inspirations, isPresented: $showingImageInput)
                    .navigationTitle("Add Image")
                    .navigationBarItems(trailing: Button("Done") {
                        showingImageInput = false
                    })
            }
        }
    }
}


