import SwiftUI
import UserNotifications

struct ReminderSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var goal: Goal
    @State private var interval: String
    @State private var selectedUnit: Goal.ReminderUnit
    @State private var nextReminderText: String = "No reminder set"
    @State private var notificationStatus: String = ""  // Add this line
    
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
                
                Section {
                    Text(nextReminderText)
                        .foregroundColor(.secondary)
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
        .onAppear {
            updateNextReminderText()
        }
    }
    
    private func updateNextReminderText() {
        guard let interval = goal.reminderInterval else {
            nextReminderText = "No reminder set"
            return
        }
        
        let intervalInSeconds: TimeInterval = {
            if goal.reminderUnit == .weeks {
                return Double(interval) * 7 * 24 * 60 * 60
            } else {
                return Double(interval) * 24 * 60 * 60
            }
        }()
        
        let now = Date()
        let lastSet = goal.lastReminderDate ?? now
        let timeElapsed = now.timeIntervalSince(lastSet)
        let remainingTime = intervalInSeconds - timeElapsed.truncatingRemainder(dividingBy: intervalInSeconds)
        
        let components = Calendar.current.dateComponents(
            [.day, .hour, .minute],
            from: now,
            to: now.addingTimeInterval(remainingTime)
        )
        
        nextReminderText = "\(components.day ?? 0) days \(components.hour ?? 0) hours \(components.minute ?? 0) mins until next reminder"
    }
    
    private func scheduleNotifications(for goal: Goal) {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else {
                DispatchQueue.main.async {
                    notificationStatus = "Notifications permission denied"
                }
                return
            }
            
            let identifier = String(describing: goal.persistentModelID)
            center.removePendingNotificationRequests(withIdentifiers: [identifier])
            
            // Schedule recurring notification
            let intervalInSeconds: Double = {
                if goal.reminderUnit == .weeks {
                    return Double(goal.reminderInterval ?? 0) * 7 * 24 * 60 * 60
                } else {
                    return Double(goal.reminderInterval ?? 0) * 24 * 60 * 60
                }
            }()
            
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
            
            center.add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error)")
                } else {
                    DispatchQueue.main.async {
                        goal.lastReminderDate = Date()
                        updateNextReminderText()
                    }
                }
            }
        }
    }
}