//
//  NotificationManager.swift
//  Limbo
//
//  Created by A-Team User on 2.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit
import UserNotifications
import MultipeerConnectivity

class NotificationManager: NSObject {
    
    static let shared = NotificationManager()
    
    func presentNotification(withMessage message:MessageModel, fromPeerID: MCPeerID, notificationDelegate: UNUserNotificationCenterDelegate) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.badge, .sound, .alert], completionHandler: { granted, error in
            DispatchQueue.main.async {
                guard granted else {
                    print("Notification not granted")
                    return
                }
                UIApplication.shared.registerForRemoteNotifications()
                let content = UNMutableNotificationContent()
                if let user = message.sender {
                    content.title = user.username
                    content.userInfo = ["chatRoomUUID": message.chatRoomUUID, "username": user.username]
                }
                
                switch message.messageType {
                case MessageType.Message.rawValue:
                    content.body = message.messageString
                case MessageType.Photo.rawValue:
                    content.body = "Photo"
                case MessageType.Message_Photo.rawValue:
                    content.body = message.messageString
                    content.subtitle = "Photo"
                case MessageType.Voice_Record.rawValue:
                    content.body = "Voice Message"
                default:
                    content.body = message.messageString
                }
                
                content.sound = UNNotificationSound.default()
                content.categoryIdentifier = Constants.Notifications.Identifiers.Message
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.01, repeats: false)
                let request = UNNotificationRequest(identifier: Constants.Notifications.Identifiers.Message, content: content, trigger: trigger)
                
                center.delegate = notificationDelegate
                center.add(request, withCompletionHandler: { (err) in
                    if let err = err {
                        print(err)
                    }
                    
                })
            }
        })
    }
    
    func presentCurseNotification(withTitle title:String, andText text:String) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.badge, .sound, .alert], completionHandler: { granted, error in
            DispatchQueue.main.async {
                guard granted else {
                    print("Notification not granted")
                    return
                }
                UIApplication.shared.registerForRemoteNotifications()
                let content = UNMutableNotificationContent()
                content.title = title
                content.body = text
                content.sound = UNNotificationSound.default()
                content.categoryIdentifier = Constants.Notifications.Identifiers.Curse
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.01, repeats: false)
                let request = UNNotificationRequest(identifier: Constants.Notifications.Identifiers.Curse, content: content, trigger: trigger)
                
                center.delegate = self
                center.add(request, withCompletionHandler: { (err) in
                    if let err = err {
                        print(err)
                    }
                })
            }
        })
    }
    
    func presentItemNotification(withTitle title:String, andText text:String) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.badge, .sound, .alert], completionHandler: { granted, error in
            DispatchQueue.main.async {
                guard granted else {
                    print("Notification not granted")
                    return
                }
                UIApplication.shared.registerForRemoteNotifications()
                let content = UNMutableNotificationContent()
                content.title = title
                content.body = text
                content.sound = UNNotificationSound.default()
                content.categoryIdentifier = Constants.Notifications.Identifiers.Item
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
                let request = UNNotificationRequest(identifier: Constants.Notifications.Identifiers.Item, content: content, trigger: trigger)
                
                center.delegate = self
                center.add(request, withCompletionHandler: { (err) in
                    if let err = err {
                        print(err)
                    }
                })
            }
        })
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
            
        case Constants.Notifications.Identifiers.CurseActionItemCandle :
            if let user = RealmManager.currentLoggedUser() {
                CurseManager.applySpecialItem(specialItem: SpecialItem.HolyCandle, toUser: user)
            }
            
        case Constants.Notifications.Identifiers.CurseActionItemMedallion :
            if let user = RealmManager.currentLoggedUser() {
                CurseManager.applySpecialItem(specialItem: .SaintsMedallion, toUser: user)
            }
        default:
            print("do nothing lol")
        }
        
        completionHandler()
    }
}
