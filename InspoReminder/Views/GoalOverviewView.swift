import SwiftUI
import SwiftData

struct GoalOverviewView: View {
    @Query private var goals: [Goal]
    
    var body: some View {
        NavigationView {
            ZStack {
                List(goals) { goal in
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