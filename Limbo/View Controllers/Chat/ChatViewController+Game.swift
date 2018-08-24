//
//  ChatViewController+Game.swift
//  Limbo
//
//  Created by A-Team User on 8.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//
let KEY_COORDINATES = "coordinates"
let KEY_NAME = "name"
let KEY_ANSWER = "answer"

let QUESTION_NAME = "What is your name?"

import Foundation
import RealmSwift

extension ChatViewController {
    func sendMessageToGame(message: String) {
        
        let messageBeforeThis = self.messages.last?.messageString
        var key: String
        
        let messageModel = MessageModel()
        messageModel.messageString = message
        messageModel.sender = self.currentUser
        if messageBeforeThis == QUESTION_NAME {
            key = KEY_NAME
        }
        else if messageBeforeThis!.contains("|") || messageBeforeThis!.contains("Invalid") {
            key = KEY_COORDINATES
        }
        else {
            key = KEY_ANSWER
        }
        let dataDict = [key: message]
        
        let success = self.chatDelegate?.sendJSONtoGame(dataDict: dataDict, toPeerID: (self.chatDelegate?.getPeerIDForUID(uniqueID: self.chatRoom!.usersPeerIDs.first!)!)!)
        if success! {
            let realm = try! Realm()
            if let userChattingWith = RealmManager.userWith(uniqueID: self.chatRoom!.usersChattingWith.first!.uniqueDeviceID, andUsername: self.chatRoom!.usersChattingWith.first!.username) {
                try? realm.write {
                    realm.add(messageModel)
//                    messageModel.receivers.append(userChattingWith)
//                    messageModel.chatRoom = self.chatRoom
                    messageModel.chatRoomUUID = self.chatRoom!.uuid
                }
            }
        }
    }
}
