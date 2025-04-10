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
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text(goal.title)
                            .font(.title2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 20)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text(goal.category.rawValue)
                            .font(.body)
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 20)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Motivation")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text(goal.motivation)
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 20)
                    
                    if !goal.inspirations.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Inspirations")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            GeometryReader { geometry in
                                let squareSize = geometry.size.width / 2 - 30
                                InspirationListView(
                                    inspirations: goal.inspirations,
                                    onDelete: { inspiration in
                                        inspirationToDelete = inspiration
                                        showingDeleteAlert = true
                                    },
                                    squareSize: squareSize
                                )
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
            trailing: Button(action: {
                showingReminderSettings = true
            }) {
                Image(systemName: "bell.circle")
                    .font(.title2)
            }
        )
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
                ImageInspirationView(inspirations: $goal.inspirations)
                    .navigationTitle("Add Image")
                    .navigationBarItems(trailing: Button("Done") {
                        showingImageInput = false
                    })
            }
        }
    }
}

struct ImageInspirationView: View {
    @Binding var inspirations: [Inspiration]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ImagePicker(inspirations: $inspirations)
            .ignoresSafeArea()
            .onAppear {
                // Dismiss the view after image is selected
                if inspirations.last?.type == .image {
                    dismiss()
                }
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
