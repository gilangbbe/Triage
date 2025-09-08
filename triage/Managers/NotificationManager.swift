//
//  NotificationManager.swift
//  triage
//
//  Created by Jason Miracle Gunawan on 08/09/25.
//

import Foundation
import SwiftUI
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    var badgeCount = 0
    
    private init() {}
    
    func scheduleLocalNotification() {
        badgeCount += 1
        
        let content = UNMutableNotificationContent()
        content.title = "Patient Reminder"
        content.body = "It's time to remind Jamir."
        content.sound = UNNotificationSound.default
        content.badge = NSNumber(value: badgeCount)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}
