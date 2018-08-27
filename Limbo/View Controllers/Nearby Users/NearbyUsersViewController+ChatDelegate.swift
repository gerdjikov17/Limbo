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
            
            if messageModel?.chatRoomUUID != self.lastSelectedChatRoomUUID {
                if let tuple = self.chatRooms.first(where: { (key, value) -> Bool in
                    value.chatRoom.uuid == messageModel?.chatRoomUUID
                }) {
                    self.chatRooms[tuple.key]?.unreadMessages += 1
                }
                
                NotificationManager.shared.presentNotification(withMessage: messageModel!, fromPeerID: fromPeerID, notificationDelegate: self)
                
            }
            self.nearbyUsersCollectionView.reloadData()
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
        let chatRoomUUID = userInfo["chatRoomUUID"] as! String
        guard let chatRoom = RealmManager.chatRoom(forUUID: chatRoomUUID) else {
            self.view.makeToast("Error sending message")
            return
        }
        let messageModel = MessageModel()
        messageModel.messageString = text
        messageModel.messageType = MessageType.Message.rawValue
        messageModel.sender = self.currentUser
        if chatRoom.usersChattingWith.count > 1 {
            messageModel.chatRoomUUID = chatRoomUUID
        }
        else {
            messageModel.chatRoomUUID = self.currentUser.uniqueDeviceID+self.currentUser.username
        }
        
        
        for user in chatRoom.usersChattingWith {
            let peerIDString = user.uniqueDeviceID
            if let peerIDSendingMessageTo = self.usersConnectivity.getPeerIDForUID(uniqueID: peerIDString) {
                self.usersConnectivity!.sendMessage(messageModel: messageModel, toPeerID: peerIDSendingMessageTo)
            }
        }
        
        
        let realm = try! Realm()
        realm.beginWrite()
        realm.add(messageModel)
        try! realm.commitWrite()
    }
    
    private func notificationTapAction(withUserInfo userInfo: [AnyHashable: Any]) {
        let chatRoomUUID = userInfo["chatRoomUUID"] as! String
        let chatVC: ChatViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chatVC") as! ChatViewController
        guard let chatRoom = RealmManager.chatRoom(forUUID: chatRoomUUID) else {
            
            self.lastSelectedChatRoomUUID = chatRoomUUID
            self.properlyPushChatVC(chatVC: chatVC)
            return
        }
        
        for peerIDString in chatRoom.usersPeerIDs {
            if let peerID = self.usersConnectivity.getPeerIDForUID(uniqueID: peerIDString) {
                if !self.usersConnectivity.session.connectedPeers.contains(peerID) {
                    self.usersConnectivity.inviteUser(peerID: peerID)
                }
            }
        }
        
//        chatVC.currentUser = self.currentUser
//        chatVC.chatRoom = chatRoom
//        chatVC.chatDelegate = self.usersConnectivity
        
        let view = ChatRouter.createChatModule(using: self.navigationController!, usersConnectivityDelegate: self.usersConnectivity, chatRoom: chatRoom)
        
        if let tuple = self.chatRooms.first(where: { (key, value) -> Bool in
            value.chatRoom.uuid == chatRoomUUID
        }) {
            self.chatRooms[tuple.key] = (tuple.value.chatRoom, 0)
        }
        
        self.lastSelectedChatRoomUUID = chatRoomUUID
        
        self.properlyPushChatVC(chatVC: view)
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

