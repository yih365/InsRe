import SwiftUI
import SwiftData

struct GoalDetailView: View {
    @Bindable var goal: Goal
    @State private var showingReminderSettings = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Title")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text(goal.title)
                        .font(.title2)
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Motivation")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text(goal.motivation)
                        .font(.body)
                }
                .padding(.horizontal)
                
                if !goal.inspirations.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Inspirations")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        ForEach(goal.inspirations) { inspiration in
                            switch inspiration.type {
                            case .text:
                                Text(inspiration.content)
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            case .link:
                                Link(inspiration.content, destination: URL(string: inspiration.content) ?? URL(string: "https://apple.com")!)
                                    .padding()
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                            case .image:
                                if let data = Data(base64Encoded: inspiration.content),
                                   let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxHeight: 200)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
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
    }
}