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
        DispatchQueue.main.async {
            let realm = try! Realm()
            let messageModel = realm.resolve(threadSafeMessageRef)
            
            if let lastSelectedPeer = self.lastSelectedPeerID {
                if lastSelectedPeer != fromPeerID {
                    let unreadMessages = self.users[lastSelectedPeer]?.unreadMessages
                    self.users[lastSelectedPeer]?.unreadMessages = unreadMessages! + 1
                    NotificationManager.shared.presentNotification(withMessage: messageModel!, fromPeerID: fromPeerID, notificationDelegate: self)
                }
            }
            else {
                if self.users.keys.contains(fromPeerID) {
                    let unreadMessages = self.users[fromPeerID]?.unreadMessages
                    self.users[fromPeerID]?.unreadMessages = unreadMessages! + 1
                }
                
                NotificationManager.shared.presentNotification(withMessage: messageModel!, fromPeerID: fromPeerID, notificationDelegate: self)
                
            }
            if let index = Array(self.users.keys).index(of: fromPeerID) {
                self.nearbyUsersCollectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
            }
        }
    }
    
}

extension NearbyUsersViewController: UNUserNotificationCenterDelegate {
    

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        guard UserDefaults.standard.bool(forKey: Constants.UserDefaults.isLoged) else {
            return
        }
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let notification = response.notification
        if notification.request.identifier == Constants.Notifications.Identifiers.Curse && notification.request.identifier == Constants.Notifications.Identifiers.Item { return }
        if response.actionIdentifier == Constants.Notifications.Identifiers.MessageActionReply {
            let response = response as! UNTextInputNotificationResponse
            let text = response.userText
            replyAction(withText: text, andUserInfo: notification.request.content.userInfo)
        }
        else {
            notificationTapAction(withUserInfo: notification.request.content.userInfo)
        }
        
        completionHandler()
    }
    
    private func replyAction(withText text: String, andUserInfo userInfo: [AnyHashable: Any]) {
        guard self.currentUser.curse != "Silence" else {
            let pointForToast = CGPoint(x: self.view.center.x, y: (self.navigationController?.navigationBar.frame.size.height)! + CGFloat(100))
            let remainingTime = Constants.Curses.curseTime + (self.currentUser?.curseCastDate?.timeIntervalSinceNow)!
            let curseRemainingTime = Int(remainingTime)
            self.view.makeToast("You are cursed with Silence", point: pointForToast, title: "You can't chat with people for \(curseRemainingTime) seconds", image: #imageLiteral(resourceName: "ghost_avatar.png"), completion: nil)
            return
        }
        let userSendingMessageToUniqueDeviceID = userInfo["uniqueDeviceID"] as! String
        let peerIDSendingMessageTo = self.usersConnectivity.getPeerIDForUID(uniqueID: userSendingMessageToUniqueDeviceID)
        guard let userSendingMessageTo = RealmManager.userWith(uniqueID: userSendingMessageToUniqueDeviceID, andUsername: userInfo["username"] as! String) else {
            return
        }
        let messageModel = MessageModel()
        messageModel.messageString = text
        messageModel.sender = self.currentUser
        
        guard let success = self.usersConnectivity?.sendMessage(messageModel: messageModel, toPeerID: peerIDSendingMessageTo!) else {
            return
        }
        if success {
            let realm = try! Realm()
            realm.beginWrite()
            realm.add(messageModel)
            messageModel.receivers.append(userSendingMessageTo)
            try! realm.commitWrite()
        }
    }
    
    private func notificationTapAction(withUserInfo userInfo: [AnyHashable: Any]) {
        let userChattingWithUniqueDeviceID = userInfo["uniqueDeviceID"] as! String
        let username = userInfo["username"] as! String
        let userChattingWith = RealmManager.userWith(uniqueID: userChattingWithUniqueDeviceID, andUsername: username)
        guard let peerIDChattingWith = self.usersConnectivity.getPeerIDForUID(uniqueID: userChattingWithUniqueDeviceID) else {
            return
        }
        let chatVC: ChatViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chatVC") as! ChatViewController
        self.usersConnectivity.inviteUser(peerID: peerIDChattingWith)
        chatVC.currentUser = self.currentUser
        chatVC.userChattingWith = userChattingWith
        chatVC.peerIDChattingWith = peerIDChattingWith
        chatVC.chatDelegate = self.usersConnectivity
        
        if (self.users.contains(where: { (key, value) -> Bool in
            key == peerIDChattingWith
        })) {
            self.users[peerIDChattingWith] = (userChattingWith!, 0)
        }
        
        self.lastSelectedPeerID = peerIDChattingWith
        
        self.properlyPushChatVC(chatVC: chatVC)
    }
    
    private func properlyPushChatVC(chatVC: ChatViewController) {
        guard var viewControllers = self.navigationController?.viewControllers else {
            return
        }
        guard let lastViewController = viewControllers.last else {
            return
        }
        if lastViewController.isKind(of: ChatViewController.self) {
            _ = viewControllers.popLast()
            viewControllers.append(chatVC)
            self.navigationController?.setViewControllers(viewControllers, animated: true)
        }
        else {
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
    }
}

