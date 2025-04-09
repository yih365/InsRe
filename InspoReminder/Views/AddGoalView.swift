import SwiftUI
import SwiftData

struct AddGoalView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var motivation = ""
    @State private var category: GoalCategory = .personalDevelopment
    @State private var inspirations: [Inspiration] = []
    
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
                    TextField("Why do you want to achieve this?", text: $motivation)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Inspirations")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    InspirationInputView(inspirations: $inspirations)
                        .padding(.horizontal)
                    
                    if !inspirations.isEmpty {
                        ForEach(inspirations) { inspiration in
                            HStack {
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
                                
                                Spacer()
                                
                                Button(action: {
                                    if let index = inspirations.firstIndex(where: { $0.id == inspiration.id }) {
                                        inspirations.remove(at: index)
                                    }
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                            .padding(.horizontal)
                        }
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
    }
}