import SwiftUI
import SwiftData

struct GoalDetailView: View {
    @Bindable var goal: Goal
    @State private var showingReminderSettings = false
    @State private var showingInspirationInput = false
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
                            
                            ForEach(goal.inspirations) { inspiration in
                                switch inspiration.type {
                                case .text:
                                    Text(inspiration.content)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                case .link:
                                    Link(inspiration.content, destination: URL(string: inspiration.content) ?? URL(string: "https://apple.com")!)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(8)
                                case .image:
                                    if let data = Data(base64Encoded: inspiration.content),
                                       let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .frame(maxHeight: 200)
                                            .cornerRadius(8)
                                    }
                                }
                                
                                Button(action: {
                                    inspirationToDelete = inspiration
                                    showingDeleteAlert = true
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                        .padding(.leading, 8)
                                }
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
                    Button(action: {
                        showingInspirationInput = true
                    }) {
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
        .sheet(isPresented: $showingInspirationInput) {
            NavigationView {
                InspirationInputView(inspirations: .init(
                    get: { goal.inspirations },
                    set: { goal.inspirations = $0 }
                ))
                .navigationTitle("Add Inspiration")
                .navigationBarItems(trailing: Button("Done") {
                    showingInspirationInput = false
                })
            }
        }
    }
}