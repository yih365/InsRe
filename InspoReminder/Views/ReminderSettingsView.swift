import SwiftUI
import UserNotifications

struct ReminderSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var goal: Goal
    @State private var interval: String
    @State private var selectedUnit: Goal.ReminderUnit
    
    init(goal: Goal) {
        self.goal = goal
        // Initialize state with existing values
        _interval = State(initialValue: goal.reminderInterval.map(String.init) ?? "")
        _selectedUnit = State(initialValue: goal.reminderUnit)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Text("Send me a reminder every")
                        TextField("0", text: $interval)
                            .keyboardType(.numberPad)
                            .frame(width: 50)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .multilineTextAlignment(.center)
                        Picker("Unit", selection: $selectedUnit) {
                            Text("days").tag(Goal.ReminderUnit.days)
                            Text("weeks").tag(Goal.ReminderUnit.weeks)
                        }
                        .pickerStyle(.segmented)
                    }
                }
            }
            .navigationTitle("Reminder Settings")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    if let intervalNum = Int(interval) {
                        goal.reminderInterval = intervalNum
                        goal.reminderUnit = selectedUnit
                        scheduleNotifications(for: goal)
                        dismiss()
                    }
                }
                .disabled(interval.isEmpty)
            )
        }
    }
    
    private func scheduleNotifications(for goal: Goal) {
        let center = UNUserNotificationCenter.current()
        
        // Request permission
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            
            // Remove existing notifications for this goal
            let identifier = String(describing: goal.persistentModelID)
            center.removePendingNotificationRequests(withIdentifiers: [identifier])
            
            // Calculate interval in seconds
            let intervalInSeconds: Double
            if goal.reminderUnit == .weeks {
                intervalInSeconds = Double(goal.reminderInterval ?? 0) * 7 * 24 * 60 * 60
            } else {
                intervalInSeconds = Double(goal.reminderInterval ?? 0) * 24 * 60 * 60
            }
            
            let content = UNMutableNotificationContent()
            content.title = "Goal Reminder: \(goal.title)"
            content.body = "Remember your motivation: \(goal.motivation)"
            
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: intervalInSeconds,
                repeats: true
            )
            
            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )
            
            center.add(request)
        }
    }
}