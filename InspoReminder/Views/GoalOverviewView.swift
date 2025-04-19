import SwiftUI
import SwiftData

struct GoalOverviewView: View {
    @Query private var goals: [Goal]
    
    private var groupedGoals: [GoalCategory: [Goal]] {
        Dictionary(grouping: goals) { $0.category }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if goals.isEmpty {
                    VStack {
                        Text("Add a goal to start.")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                } else {
                    List {
                        ForEach(GoalCategory.allCases, id: \.self) { category in
                            if let goalsInCategory = groupedGoals[category], !goalsInCategory.isEmpty {
                                Section {
                                    ForEach(goalsInCategory) { goal in
                                        NavigationLink(destination: GoalDetailView(goal: goal)) {
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text(goal.title)
                                                    .font(.headline)
                                                Text(goal.motivation)
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                                
                                                if !goal.inspirations.isEmpty {
                                                    ScrollView(.horizontal, showsIndicators: false) {
                                                        HStack(spacing: 10) {
                                                            ForEach(goal.inspirations) { inspiration in
                                                                InspirationPreviewView(inspiration: inspiration)
                                                                    .frame(width: 100, height: 100)
                                                            }
                                                        }
                                                        .padding(.vertical, 5)
                                                    }
                                                    .overlay(
                                                        HStack {
                                                            LinearGradient(
                                                                gradient: Gradient(colors: [Color(UIColor.systemBackground), .clear]),
                                                                startPoint: .leading,
                                                                endPoint: .trailing
                                                            )
                                                            .frame(width: 20)
                                                            Spacer()
                                                            LinearGradient(
                                                                gradient: Gradient(colors: [.clear, Color(UIColor.systemBackground)]),
                                                                startPoint: .leading,
                                                                endPoint: .trailing
                                                            )
                                                            .frame(width: 20)
                                                        }
                                                    )
                                                }
                                            }
                                        }
                                    }
                                } header: {
                                    HStack {
                                        Text(category.rawValue)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Spacer()
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal)
                                    .background(Color.black)
                                    .listRowInsets(EdgeInsets())
                                }
                                .listSectionSeparator(.hidden)
                            }
                        }
                    }
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NavigationLink(destination: AddGoalView()) {
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
            .navigationTitle("My Goals")
        }
    }
}