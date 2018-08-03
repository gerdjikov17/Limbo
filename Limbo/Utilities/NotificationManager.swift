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
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert], completionHandler: { granted, error in
            DispatchQueue.main.async {
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                    let content = UNMutableNotificationContent()
                    if let user = message.sender {
                        content.title = user.username
                        content.userInfo = ["uniqueDeviceID": user.uniqueDeviceID]
                    }
                    
                    content.body = message.messageString
                    content.sound = UNNotificationSound.default()
                    
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.01, repeats: false)
                    let request = UNNotificationRequest(identifier: Constants.Notifications.Identifiers.Message, content: content, trigger: trigger)
                    let center = UNUserNotificationCenter.current()
                    center.delegate = notificationDelegate
                    center.add(request, withCompletionHandler: { (err) in
                        if let err = err {
                            print(err)
                        }
                        
                    })
                }
                else {
                    //Do stuff if unsuccessful...
                }
            }
        })
    }
    
    func presentNotification(withTitle title:String, andText text:String) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert], completionHandler: { granted, error in
            DispatchQueue.main.async {
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                    let content = UNMutableNotificationContent()
                    content.title = title
                    content.body = text
                    content.sound = UNNotificationSound.default()
                    
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.01, repeats: false)
                    let request = UNNotificationRequest(identifier: Constants.Notifications.Identifiers.Curse, content: content, trigger: trigger)
                    let center = UNUserNotificationCenter.current()
                    center.delegate = self
                    center.add(request, withCompletionHandler: { (err) in
                        if let err = err {
                            print(err)
                        }
                    })
                }
                else {
                    //Do stuff if unsuccessful...
                }
            }
        })
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}
