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
                List {
                    ForEach(GoalCategory.allCases, id: \.self) { category in
                        if let goalsInCategory = groupedGoals[category], !goalsInCategory.isEmpty {
                            Section(header: Text(category.rawValue)) {
                                ForEach(goalsInCategory) { goal in
                                    NavigationLink(destination: GoalDetailView(goal: goal)) {
                                        VStack(alignment: .leading) {
                                            Text(goal.title)
                                                .font(.headline)
                                            Text(goal.motivation)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
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