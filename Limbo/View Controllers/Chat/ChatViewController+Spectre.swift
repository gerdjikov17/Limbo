//
//  ChatViewController+Spectre.swift
//  Limbo
//
//  Created by A-Team User on 1.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit

extension ChatViewController {
    func sendingMessageWhileSilenced() {
        let pointForToast = CGPoint(x: self.view.center.x, y: (self.navigationController?.navigationBar.frame.size.height)! + CGFloat(100))
        let remainingTime = Constants.Curses.curseTime + (self.currentUser?.curseCastDate?.timeIntervalSinceNow)!
        let curseRemainingTime = Int(remainingTime)
        self.view.makeToast("You are cursed with Silence", point: pointForToast, title: "You can't chat with people for \(curseRemainingTime) seconds", image: #imageLiteral(resourceName: "ghost_avatar.png"), completion: nil)
    }
    
    func sendMessageToSpectre(message: String) {
        let messageModel = MessageModel()
        messageModel.messageString = message
        messageModel.messageType = MessageType.Message.rawValue
        let realm = try! Realm()
        let spectre = realm.objects(UserModel.self).filter("state = %@", "Spectre").first
        try? realm.write {
            realm.add(messageModel)
            messageModel.sender = self.currentUser
//            messageModel.receivers.append(spectre!)
//            messageModel.chatRoom = RealmManager.chatRoom(forUUID: spectre!.compoundKey)
            messageModel.chatRoomUUID = spectre!.compoundKey
        }
        self.receiveMessageFromSpectre(forMessage: message)
    }
    
    func receiveMessageFromSpectre(forMessage: String) {
        let messageModel = MessageModel()
        
        messageModel.messageString = Spectre.properAnswer(forMessage: forMessage)
        messageModel.messageType = MessageType.Message.rawValue
        let realm = try! Realm()
        let spectreUser = realm.objects(UserModel.self).filter("state = %@", "Spectre").first
        messageModel.chatRoomUUID = spectreUser!.compoundKey
        messageModel.sender = spectreUser
        try? realm.write {
            realm.add(messageModel)
//            messageModel.receivers.append(self.currentUser!)
//            messageModel.chatRoom = RealmManager.chatRoom(forUUID: spectreUser!.compoundKey)
            
        }

    }
}
