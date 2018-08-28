//
//  AlarmController.swift
//  Alarm
//
//  Created by John Tate on 8/27/18.
//  Copyright © 2018 John Tate. All rights reserved.
//

import Foundation
import UserNotifications

protocol AlarmScheduler: class {
    
    func scheduleUserNotifications()
    func cancelUserNotifications()
    
}

extension AlarmScheduler {
    
    func scheduleUserNotifications(for alarm: Alarm){
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Alarm"
        notificationContent.body = alarm.name
        notificationContent.sound = UNNotificationSound.default()
        
        guard let fireDate = alarm.fireDate else {return}
        let dateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: alarm.uuid, content: notificationContent, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error{
                print("Unable to add Notification Request \(error) \(error.localizedDescription)")
            }
        }
    }
    
    func cancelUserNotifications(for alarm: Alarm){
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [alarm.uuid])
    }
}


class AlarmController: AlarmScheduler {
    func cancelUserNotifications() {
        cancelUserNotifications()
    }
    
    func scheduleUserNotifications() {
        scheduleUserNotifications()
    }
    
    static let shared = AlarmController()
    
    var alarms: [Alarm] = []
        
    func addAlarm(fireTimeFromMidnight: TimeInterval, name: String) {
        let newAlarm = Alarm(fireTimeFromMidnight: fireTimeFromMidnight, name: name)
        alarms.append(newAlarm)
        scheduleUserNotifications(for: newAlarm)
        saveToPersistentStorage()
    }
    
    func update(alarm: Alarm, fireTimeFromMidnight: TimeInterval, name: String){
        // Cancel user notifications for the old alarm
        cancelUserNotifications(for: alarm)
        
        alarm.name = name
        alarm.fireTimeFromMidnight = fireTimeFromMidnight
        
        // Schedule user notifications for the updated alarm
        scheduleUserNotifications(for: alarm)
        
        saveToPersistentStorage()
    }
    
    func delete(alarm: Alarm){
        if let indexOfAlarmBeingDeleted = alarms.index(of: alarm){
            alarms.remove(at: indexOfAlarmBeingDeleted)
        }
        // Cancel user notifications if alarm is deleted
        cancelUserNotifications(for: alarm)
        
        saveToPersistentStorage()
    }
    
    func toggledEnabled(for alarm: Alarm){
        // If alarm being turned off, then need to cancel user notifications.  If being turned on, need to schedule user notifications.
        if alarm.enabled {
            cancelUserNotifications(for: alarm)
        } else {
            scheduleUserNotifications(for: alarm)
        }
        // Toggle the alarm
        alarm.enabled = !alarm.enabled
        
        saveToPersistentStorage()
    }
    
    // Persistence
    
    // Get URL from File Manager
    func fileURL() -> URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let fileName = "Task.json"
        let documentsDirectoryURL = urls[0].appendingPathComponent(fileName)
        return documentsDirectoryURL
    }
    
    func loadFromPersistentStorage(){
        let decoder = JSONDecoder()
        do {
            let data = try Data(contentsOf: fileURL())
            let decodedAlarms = try decoder.decode([Alarm].self, from: data)
            self.alarms = decodedAlarms
        } catch {
            print("Error loading from persistence: \(error.localizedDescription)")
        }
    }
    
    func saveToPersistentStorage(){
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(alarms)
            try data.write(to: fileURL())
        } catch {
            print("Error saving to persistence: \(error.localizedDescription)")
        }
    }
    
}
