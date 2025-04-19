import SwiftUI
import SwiftData

struct GoalDetailView: View {
    @Bindable var goal: Goal
    @State private var showingReminderSettings = false
    @State private var showingMenu = false
    @State private var showingTextInput = false
    @State private var showingLinkInput = false
    @State private var showingImageInput = false
    @State private var inspirationToDelete: Inspiration?
    @State private var showingDeleteAlert = false
    @State private var inspirationViewMode: InspirationType = .grid
    @State private var showingEditSheet = false
    @State private var showingDeleteGoalAlert = false
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(goal.title)
                        .font(.title2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                    
                    Text(goal.category.rawValue)
                        .font(.body)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 20)
                        .background(Color(red: 0.7, green: 0.5, blue: 0.8))
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                    
                    Text(goal.motivation)
                        .font(.body)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 20)
                        .background(Color(red: 0.5, green: 0.7, blue: 0.5))
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                    
                    Divider()
                        .padding(.horizontal, 20)
                    
                    if !goal.inspirations.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Inspirations")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 20)
                                    .background(Color.black)
                                    .cornerRadius(10)
                                Spacer()
                                Picker("View Mode", selection: $inspirationViewMode) {
                                    Image(systemName: "square.grid.2x2").tag(InspirationType.grid)
                                    Image(systemName: "list.bullet").tag(InspirationType.list)
                                }
                                .pickerStyle(.segmented)
                                .frame(width: 100)
                            }
                            .padding(.horizontal, 20)
                            
                            switch inspirationViewMode {
                            case .grid:
                                GeometryReader { geometry in
                                    InspirationListView(
                                        inspirations: goal.inspirations,
                                        onDelete: { inspiration in
                                            inspirationToDelete = inspiration
                                            showingDeleteAlert = true
                                        },
                                        onFavorite: { inspiration in
                                            inspiration.isFavorite.toggle()
                                        }
                                    )
                                }
                                .frame(height: CGFloat(ceil(Double(goal.inspirations.count) / 2.0)) * 200)
                            case .list:
                                VStack(spacing: 20) {
                                    InspirationCarouselView(
                                        inspirations: goal.inspirations,
                                        title: "Images",
                                        onDelete: { inspiration in
                                            inspirationToDelete = inspiration
                                            showingDeleteAlert = true
                                        },
                                        onFavorite: { inspiration in
                                            inspiration.isFavorite.toggle()
                                        }
                                    )
                                    
                                    InspirationCarouselView(
                                        inspirations: goal.inspirations,
                                        title: "Text",
                                        onDelete: { inspiration in
                                            inspirationToDelete = inspiration
                                            showingDeleteAlert = true
                                        },
                                        onFavorite: { inspiration in
                                            inspiration.isFavorite.toggle()
                                        }
                                    )
                                    
                                    InspirationCarouselView(
                                        inspirations: goal.inspirations,
                                        title: "Links",
                                        onDelete: { inspiration in
                                            inspirationToDelete = inspiration
                                            showingDeleteAlert = true
                                        },
                                        onFavorite: { inspiration in
                                            inspiration.isFavorite.toggle()
                                        }
                                    )
                                }
                                EmptyView() // Placeholder for the list view
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.vertical)
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
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
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding()
                }
            }
        }
        .alert("Delete Inspiration?", isPresented: $showingDeleteAlert, presenting: inspirationToDelete) { inspiration in
            Button("Delete", role: .destructive) {
                if let index = goal.inspirations.firstIndex(where: { $0.id == inspiration.id }) {
                    goal.inspirations.remove(at: index)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: { _ in
            Text("This action cannot be undone.")
        }
        .navigationTitle("Goal Details")
        .navigationBarItems(
            trailing: HStack {
                Button(action: {
                    showingReminderSettings = true
                }) {
                    Image(systemName: "bell.circle")
                        .font(.title2)
                }
                
                Button(action: {
                    showingEditSheet = true
                }) {
                    Image(systemName: "gear")
                        .font(.title2)
                }
            }
        )
        .sheet(isPresented: $showingEditSheet) {
            NavigationView {
                Form {
                    TextField("Title", text: $goal.title)
                    Picker("Category", selection: $goal.category) {
                        ForEach(GoalCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    TextField("Motivation", text: $goal.motivation, axis: .vertical)
                        .lineLimit(1...5)
                    
                    Section {
                        Button("Delete Goal", role: .destructive) {
                            showingDeleteGoalAlert = true
                        }
                    }
                }
                .navigationTitle("Edit Goal")
                .navigationBarItems(trailing: Button("Done") {
                    showingEditSheet = false
                })
            }
        }
        .alert("Delete Goal?", isPresented: $showingDeleteGoalAlert) {
            Button("Delete", role: .destructive) {
                modelContext.delete(goal)
                try? modelContext.save()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this goal? This action cannot be undone.")
        }
        .sheet(isPresented: $showingReminderSettings) {
            ReminderSettingsView(goal: goal)
        }
        .sheet(isPresented: $showingTextInput) {
            NavigationView {
                TextInspirationView(inspirations: $goal.inspirations, isPresented: $showingTextInput)
                    .navigationTitle("Add Text")
            }
        }
        .sheet(isPresented: $showingLinkInput) {
            NavigationView {
                LinkInspirationView(inspirations: $goal.inspirations, isPresented: $showingLinkInput)
                    .navigationTitle("Add Link")
            }
        }
        .sheet(isPresented: $showingImageInput) {
            NavigationView {
                ImageInspirationView(inspirations: $goal.inspirations, isPresented: $showingImageInput)
                    .navigationTitle("Add Image")
            }
        }
    }
}

struct ImageInspirationView: View {
    @Binding var inspirations: [Inspiration]
    @Environment(\.dismiss) private var dismiss
    @Binding var isPresented: Bool
    
    var body: some View {
        ImagePicker(inspirations: $inspirations)
            .ignoresSafeArea()
            .onChange(of: inspirations.count) { _, _ in
                isPresented = false
                dismiss()
            }
            .onDisappear {
                isPresented = false
                dismiss()
            }
    }
}

struct TextInspirationView: View {
    @Binding var inspirations: [Inspiration]
    @State private var text = ""
    @Environment(\.dismiss) private var dismiss
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Enter your inspiration", text: $text, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Add") {
                if !text.isEmpty {
                    inspirations.append(Inspiration(type: .text, content: text))
                    isPresented = false
                    dismiss()
                }
            }
            .disabled(text.isEmpty)
            .buttonStyle(.borderedProminent)
            .padding()
            
            Spacer()
        }
    }
}

struct LinkInspirationView: View {
    @Binding var inspirations: [Inspiration]
    @State private var link = ""
    @Environment(\.dismiss) private var dismiss
    @Binding var isPresented: Bool
    
    private func formatURL(_ urlString: String) -> String {
        if !urlString.lowercased().hasPrefix("http://") && !urlString.lowercased().hasPrefix("https://") {
            return "https://" + urlString
        }
        return urlString
    }
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Enter URL", text: $link)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.URL)
                .autocapitalization(.none)
                .padding()
            
            Button("Add") {
                if !link.isEmpty {
                    let formattedLink = formatURL(link)
                    inspirations.append(Inspiration(type: .link, content: formattedLink))
                    isPresented = false
                    dismiss()
                }
            }
            .disabled(link.isEmpty)
            .buttonStyle(.borderedProminent)
            .padding()
            
            Spacer()
        }
    }
}

private enum InspirationType {
    case grid, list
}
                        
