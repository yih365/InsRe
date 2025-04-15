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
            TabView {
                GoalOverviewView()
                    .tabItem {
                        Label("Goals", systemImage: "target")
                    }
                
                InspirationGalleryView()
                    .tabItem {
                        Label("All Inspirations", systemImage: "sparkles")
                    }
            }
        }
        .modelContainer(container)
    }
}
