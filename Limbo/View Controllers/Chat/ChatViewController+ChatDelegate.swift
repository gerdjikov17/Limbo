//
//  ChatViewController+ChatDelegate.swift
//  Limbo
//
//  Created by A-Team User on 31.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import Foundation
import RealmSwift
import MultipeerConnectivity
import UserNotifications

extension ChatViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let notification = response.notification
        let userInfo = notification.request.content.userInfo
        let userChattingWithUniqueDeviceID = userInfo["uniqueDeviceID"] as! String
        let username = userInfo["username"] as! String
        let userChattingWith = RealmManager.userWith(uniqueID: userChattingWithUniqueDeviceID, andUsername: username)
        let peerIDChattingWith = self.chatDelegate?.getPeerIDForUID(uniqueID: userChattingWithUniqueDeviceID)
        let chatVC: ChatViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chatVC") as! ChatViewController
        chatVC.currentUser = self.currentUser
//        chatVC.userChattingWith = userChattingWith
//        chatVC.peerIDChattingWith = peerIDChattingWith
//        to do here
        chatVC.chatDelegate = self.chatDelegate
        var viewControllers = self.navigationController?.viewControllers
        viewControllers?.removeLast()
        viewControllers?.append(chatVC)
        self.navigationController?.setViewControllers(viewControllers!, animated: true)
        
        completionHandler()
    }
}
