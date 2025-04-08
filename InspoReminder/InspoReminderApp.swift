import SwiftUI
import SwiftData

@main
struct InspoReminderApp: App {
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: Goal.self)
        } catch {
            fatalError("Failed to initialize ModelContainer")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            GoalOverviewView()
        }
        .modelContainer(container)
    }
}
