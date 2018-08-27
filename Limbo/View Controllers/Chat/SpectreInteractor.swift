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

class SpectreInteractor {
    
    static func sendMessageToSpectre(message: String) {
        let messageModel = MessageModel()
        messageModel.messageString = message
        messageModel.messageType = MessageType.Message.rawValue
        let realm = try! Realm()
        let spectre = realm.objects(UserModel.self).filter("state = %@", "Spectre").first
        try? realm.write {
            realm.add(messageModel)
            messageModel.sender = RealmManager.currentLoggedUser()
            messageModel.chatRoomUUID = spectre!.compoundKey
        }
        self.receiveMessageFromSpectre(forMessage: message)
    }
    
    static func receiveMessageFromSpectre(forMessage: String) {
        let messageModel = MessageModel()
        
        messageModel.messageString = Spectre.properAnswer(forMessage: forMessage)
        messageModel.messageType = MessageType.Message.rawValue
        let realm = try! Realm()
        let spectreUser = realm.objects(UserModel.self).filter("state = %@", "Spectre").first
        messageModel.chatRoomUUID = spectreUser!.compoundKey
        messageModel.sender = spectreUser
        try? realm.write {
            realm.add(messageModel)
        }
    }
}
