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
                                            VStack(alignment: .leading) {
                                                Text(goal.title)
                                                    .font(.headline)
                                                Text(goal.motivation)
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
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