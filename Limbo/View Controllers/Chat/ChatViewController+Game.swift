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
        else if messageBeforeThis!.contains("|") {
            key = KEY_COORDINATES
        }
        else {
            key = KEY_ANSWER
        }
        let dataDict = [key: message]
        let success = self.chatDelegate?.sendJSONtoGame(dataDict: dataDict, toPeerID: self.peerIDChattingWith!)
        if success! {
            self.messages.append(messageModel)
            let realm = try! Realm()
            if let userChattingWith = RealmManager.userWith(uniqueID: (self.userChattingWith?.uniqueDeviceID)!) {
                try? realm.write {
                    realm.add(messageModel)
                    messageModel.receivers.append(userChattingWith)
                }
                let indexOfMessage = self.messages.count - 1
                let indexPath = IndexPath(row: indexOfMessage, section: 0)
                self.chatTableView.insertRows(at: [indexPath], with: .middle)
                self.chatTableView.scrollToRow(at: indexPath, at: .middle, animated: true)
            }
        }
    }
}
