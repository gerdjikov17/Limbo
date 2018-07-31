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
import LNRSimpleNotifications

extension NearbyUsersViewController: ChatDelegate {
    
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
            let senderUser = messageModel?.sender
            let notificationManager = LNRNotificationManager()
            notificationManager.notificationsPosition = .top
            notificationManager.notificationsBackgroundColor = .white
            notificationManager.notificationsTitleTextColor = .black
            notificationManager.notificationsBodyTextColor = .darkGray
            notificationManager.notificationsSeperatorColor = .gray
            
            notificationManager.showNotification(notification: LNRNotification(title: (senderUser?.username)!, body:messageModel?.messageString , duration: 3, onTap: {
                
                let chatVC: ChatViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chatVC") as! ChatViewController
                self.usersConnectivity.inviteUser(peerID: fromPeerID)
                chatVC.currentUser = self.currentUser
                chatVC.userChattingWith = senderUser
                chatVC.peerIDChattingWith = fromPeerID
                chatVC.chatDelegate = self.usersConnectivity
                self.usersConnectivity.chatDelegate = chatVC
                self.navigationController?.pushViewController(chatVC, animated: true)
                
            }, onTimeout: {
                
            }))
        }
    }
    
    @objc func reloadDataFromSelector() {
        DispatchQueue.main.async {
            self.nearbyUsersCollectionView.reloadData()
            self.setUIContent(userModel: self.currentUser)
        }
    }
    
}
