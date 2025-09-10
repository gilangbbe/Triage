//
//  NotificationManager.swift
//  triage
//
//  Created by Jason Miracle Gunawan on 08/09/25.
//

import Foundation
import SwiftUI
import UserNotifications

@Observable
class NotificationManager {
    static let shared = NotificationManager()
    
    private let center = UNUserNotificationCenter.current()
    
    var badgeCount = 0
    
    private init() {}
    
    func scheduleReminder(for appointment: Appointment, hoursBefore: Int = 2) {
        badgeCount += 1
        
        let content = UNMutableNotificationContent()
        content.title = "Patient Reminder"
        content.body = "It's time to remind \(appointment.patient?.fullName ?? "Patient")"
        content.sound = UNNotificationSound.default
        content.badge = NSNumber(value: badgeCount)
        
        // Get Appointment Datetime
        let appointmentDate = appointment.timeSlot.startTime
        
        // Calculate Reminder Time (Event - 2 hours)
        guard let reminderDate = Calendar.current.date(byAdding: .hour, value: -hoursBefore, to: appointmentDate) else {
            print("Reminder time already passed or invalid")
            return
        }
        
        let triggerDate =  Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: appointment.id.uuidString, content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling reminder")
            } else {
                print("Reminder scheduled successfully")
            }
        }
    }
    
    func removeReminder(for appointment: Appointment) {
        center.removePendingNotificationRequests(withIdentifiers: [appointment.id.uuidString])
    }
    
    func rescheduleReminders(for appointments: [Appointment], hoursBefore: Int = 2) {
        center.removeAllPendingNotificationRequests()
        
        for appointment in appointments {
            scheduleReminder(for: appointment, hoursBefore: hoursBefore)
        }
    }
}
