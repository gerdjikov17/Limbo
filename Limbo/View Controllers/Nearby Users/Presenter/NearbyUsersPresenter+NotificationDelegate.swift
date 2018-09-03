//
//  NearbyUsersInteractor+NotificationDelegate.swift
//  Limbo
//
//  Created by A-Team User on 28.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import Foundation
import UserNotifications

extension NearbyUsersPresenter: UNUserNotificationCenterDelegate {
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        guard UserDefaults.standard.bool(forKey: Constants.UserDefaults.isLoged) else {
            return
        }
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let notification = response.notification
        if notification.request.identifier == Constants.Notifications.Identifiers.Curse &&
            notification.request.identifier == Constants.Notifications.Identifiers.Item { return }
        if response.actionIdentifier == Constants.Notifications.Identifiers.MessageActionReply {
            let response = response as! UNTextInputNotificationResponse
            let text = response.userText
            let result = self.interactor.replyAction(withText: text, andUserInfo: notification.request.content.userInfo)
            if !result.success {
                self.view.showToast(message: result.toastMessage!)
            }
            
        } else {
            self.notificationTapAction(withUserInfo: notification.request.content.userInfo)
        }
        
        completionHandler()
    }
    
    private func notificationTapAction(withUserInfo userInfo: [AnyHashable: Any]) {
        let chatRoomUUID = userInfo["chatRoomUUID"] as! String
        guard let chatRoom = RealmManager.chatRoom(forUUID: chatRoomUUID) else { return }
        
        self.interactor.inviteUsersIn(chatRoom: chatRoom)
        self.interactor.didSelectRoom(withUUID: chatRoomUUID)
        
        self.router.createAndPushChatModule(chatRoom: chatRoom,
                                            usersConnectivityDelegate: self.interactor.usersConnectivityDelegate())
    }
}

