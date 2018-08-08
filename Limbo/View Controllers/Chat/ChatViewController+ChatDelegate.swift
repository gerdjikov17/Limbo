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

extension ChatViewController: ChatDelegate {
    
    func didReceiveCurse(curse: Curse, remainingTime: Double) {

    }
    
    func didReceiveMessage(threadSafeMessageRef: ThreadSafeReference<MessageModel>, fromPeerID: MCPeerID) {
        DispatchQueue.main.async {
            let realm = try! Realm()
            let messageModel = realm.resolve(threadSafeMessageRef)
            if fromPeerID.displayName == self.peerIDChattingWith?.displayName {
                
                self.messages.append(messageModel!)
                let indexOfMessage = self.messages.count - 1
                let indexPath = IndexPath(row: indexOfMessage, section: 0)
                self.chatTableView.insertRows(at: [indexPath], with: .middle)
                self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
            else {
                
                NotificationManager.shared.presentNotification(withMessage: messageModel!, fromPeerID: fromPeerID, notificationDelegate: self)
            }
        }
    }
}

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
        chatVC.userChattingWith = userChattingWith
        chatVC.peerIDChattingWith = peerIDChattingWith
        chatVC.chatDelegate = self.chatDelegate
        self.chatDelegate?.setChatDelegate(newDelegate: chatVC)
        var viewControllers = self.navigationController?.viewControllers
        viewControllers?.removeLast()
        viewControllers?.append(chatVC)
        self.navigationController?.setViewControllers(viewControllers!, animated: true)
        
        completionHandler()
    }
}
