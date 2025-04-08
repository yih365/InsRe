import Foundation
import SwiftData

@Model
final class Goal {
    var title: String
    var motivation: String
    @Relationship(deleteRule: .cascade) var inspirations: [Inspiration]
    var reminderInterval: Int?
    var reminderUnit: ReminderUnit
    var lastReminderDate: Date?
    
    enum ReminderUnit: String, Codable {
        case days
        case weeks
    }
    
    init(title: String, motivation: String) {
        self.title = title
        self.motivation = motivation
        self.inspirations = []
        self.reminderUnit = .days
    }
}