//
//  ChatViewController+ChatDelegate.swift
//  Limbo
//
//  Created by A-Team User on 31.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import Foundation
import RealmSwift
import LNRSimpleNotifications
import MultipeerConnectivity

extension ChatViewController: ChatDelegate {
    
    func didReceiveCurse(curse: Curse, remainingTime: Double) {
        DispatchQueue.main.async {
            let notificationManager = LNRNotificationManager()
            notificationManager.notificationsPosition = .top
            notificationManager.notificationsBackgroundColor = .white
            notificationManager.notificationsTitleTextColor = .black
            notificationManager.notificationsBodyTextColor = .darkGray
            notificationManager.notificationsSeperatorColor = .gray
            
            let roundedRemainingTime = Int(remainingTime)
            notificationManager.showNotification(notification: LNRNotification(title: "You have been cursed", body: String(curse.rawValue + " for \(roundedRemainingTime) seconds"), duration: 3, onTap: {
                
            }, onTimeout: {
                
            }))
            
        }
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
                
                let notificationManager = LNRNotificationManager()
                notificationManager.notificationsPosition = .top
                notificationManager.notificationsBackgroundColor = .white
                notificationManager.notificationsTitleTextColor = .black
                notificationManager.notificationsBodyTextColor = .darkGray
                notificationManager.notificationsSeperatorColor = .gray
                
                notificationManager.showNotification(notification: LNRNotification(title: (messageModel?.sender?.username)!, body:messageModel?.messageString , duration: 3, onTap: {
                    
                    let chatVC: ChatViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chatVC") as! ChatViewController
                    chatVC.currentUser = self.currentUser
                    chatVC.userChattingWith = messageModel?.sender
                    chatVC.peerIDChattingWith = fromPeerID
                    chatVC.chatDelegate = self.chatDelegate
                    self.chatDelegate?.setChatDelegate(newDelegate: chatVC)
                    var viewControllers = self.navigationController?.viewControllers
                    viewControllers?.removeLast()
                    viewControllers?.append(chatVC)
                    self.navigationController?.setViewControllers(viewControllers!, animated: true)
                    
                }, onTimeout: {
                    
                }))
            }
        }
    }
}
