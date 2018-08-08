//
//  NearbyUsersViewController+ChatDelegate.swift
//  Limbo
//
//  Created by A-Team User on 31.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import Foundation
import RealmSwift
import MultipeerConnectivity
import UserNotifications

extension NearbyUsersViewController: ChatDelegate {
    
    func didReceiveCurse(curse: Curse, remainingTime: Double) {
        
        DispatchQueue.main.async {
            if curse == .Blind {
                self.nearbyUsersCollectionView.reloadData()
                
                let timer = Timer.init(fireAt: Date(timeIntervalSinceNow: remainingTime), interval: 0, target: self, selector: #selector(self.reloadDataFromSelector), userInfo: nil, repeats: false)
                RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
            }
        }
    }
    
    func didReceiveMessage(threadSafeMessageRef: ThreadSafeReference<MessageModel>, fromPeerID: MCPeerID) {
        //        create a notificiation that message is received
        DispatchQueue.main.async {
            let realm = try! Realm()
            let messageModel = realm.resolve(threadSafeMessageRef)
            NotificationManager.shared.presentNotification(withMessage: messageModel!, fromPeerID: fromPeerID, notificationDelegate: self)
        }
    }
    
    @objc func reloadDataFromSelector() {
//        self.usersConnectivity = UsersConnectivity(userModel: self.currentUser, delegate: self)
//        self.usersConnectivity.chatDelegate = self
        DispatchQueue.main.async {
            self.nearbyUsersCollectionView.reloadData()
            self.setUIContent(userModel: self.currentUser)
        }
    }
    
}

extension NearbyUsersViewController: UNUserNotificationCenterDelegate {
    

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let notification = response.notification
        if notification.request.identifier == Constants.Notifications.Identifiers.Curse { return }
        if response.actionIdentifier == Constants.Notifications.Identifiers.MessageActionReply {
            let response = response as! UNTextInputNotificationResponse
            let text = response.userText
            let userInfo = notification.request.content.userInfo
            let userChattingWithUniqueDeviceID =  userInfo["uniqueDeviceID"] as! String
            let peerIDChattingWith = self.usersConnectivity.getPeerIDForUID(uniqueID: userChattingWithUniqueDeviceID)
            let userChattingWith = RealmManager.userWith(uniqueID: userChattingWithUniqueDeviceID, andUsername: userInfo["username"] as! String)
            let messageModel = MessageModel()
            messageModel.messageString = text
            messageModel.sender = self.currentUser
            let success = self.usersConnectivity?.sendMessage(messageModel: messageModel, toPeerID: peerIDChattingWith!)
            if success! {
                let realm = try! Realm()
                if let userChattingWith = RealmManager.userWith(uniqueID: (userChattingWith?.uniqueDeviceID)!, andUsername: (userChattingWith?.username)!) {
                    try? realm.write {
                        realm.add(messageModel)
                        messageModel.receivers.append(userChattingWith)
                    }
                }
            }
        }
        else {
            let userInfo = notification.request.content.userInfo
            let userChattingWithUniqueDeviceID = userInfo["uniqueDeviceID"] as! String
            let username = userInfo["username"] as! String
            let userChattingWith = RealmManager.userWith(uniqueID: userChattingWithUniqueDeviceID, andUsername: username)
            if let peerIDChattingWith = self.usersConnectivity.getPeerIDForUID(uniqueID: userChattingWithUniqueDeviceID) {
                let chatVC: ChatViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chatVC") as! ChatViewController
                self.usersConnectivity.inviteUser(peerID: peerIDChattingWith)
                chatVC.currentUser = self.currentUser
                chatVC.userChattingWith = userChattingWith
                chatVC.peerIDChattingWith = peerIDChattingWith
                chatVC.chatDelegate = self.usersConnectivity
                self.usersConnectivity.chatDelegate = chatVC
                self.navigationController?.pushViewController(chatVC, animated: true)
            }
        }
        
        
        
        completionHandler()
    }
}

