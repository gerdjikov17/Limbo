//
//  ChatRepositoryModel.swift
//  Limbo
//
//  Created by A-Team User on 24.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit
import RealmSwift
import MultipeerConnectivity

class ChatRepositoryModel: NSObject {
    
    var chatDelegate: UsersConnectivityDelegate?
    var chatRoom: ChatRoomModel?
    var currentUser: UserModel?
    var messagesResults: Results<MessageModel>!
    var messages: [MessageModel]!
    var startIndex: Int! {
        get {
            var returnIndex = self.messagesResults.count - self.rangeOfMessagesToShow
            if returnIndex < 0 {
                returnIndex = 0
            }
            return returnIndex
        }
    }
    var selectedIndexPathForTimeStamp: IndexPath?
    var notificationToken: NotificationToken!
    var rangeOfMessagesToShow = 50
    
    var voiceRecorder: VoiceRecorder?
    
    func sendMessageToUser(message: String) {
        let messageModel = MessageModel()
        messageModel.messageString = message
        messageModel.messageType = MessageType.Message.rawValue
        messageModel.sender = self.currentUser
        if (self.chatRoom?.usersChattingWith.count)! > 1 {
            messageModel.chatRoomUUID = self.chatRoom!.uuid
        }
        else {
            messageModel.chatRoomUUID = self.currentUser!.uniqueDeviceID.appending(self.currentUser!.username)
        }
        
        for user in chatRoom!.usersChattingWith {
            if let peerID = self.chatDelegate?.getPeerIDForUID(uniqueID: user.uniqueDeviceID) {
                _ = self.chatDelegate!.sendMessage(messageModel: messageModel, toPeerID: peerID)
            }
        }
        let realm = try! Realm()
        try? realm.write {
            messageModel.chatRoomUUID = self.chatRoom!.uuid
            realm.add(messageModel)
        }
    }
}
