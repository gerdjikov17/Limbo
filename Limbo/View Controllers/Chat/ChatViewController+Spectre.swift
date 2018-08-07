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
        self.messages.append(messageModel)
        let realm = try! Realm()
        let spectre = realm.objects(UserModel.self).filter("state = %@", "Spectre").first
        try? realm.write {
            realm.add(messageModel)
            messageModel.sender = self.currentUser
            messageModel.receivers.append(spectre!)
            
            let indexOfMessage = self.messages.count - 1
            let indexPath = IndexPath(row: indexOfMessage, section: 0)
            self.chatTableView.insertRows(at: [indexPath], with: .middle)
            self.chatTableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        }
        self.receiveMessageFromSpectre(forMessage: message)
    }
    
    func receiveMessageFromSpectre(forMessage: String) {
        let messageModel = MessageModel()
        
        messageModel.messageString = Spectre.properAnswer(forMessage: forMessage)

        let realm = try! Realm()
        let spectreUser = realm.objects(UserModel.self).filter("state = %@", "Spectre").first
        try? realm.write {
            realm.add(messageModel)
            messageModel.sender = spectreUser
            messageModel.receivers.append(self.currentUser!)
            
            self.messages.append(messageModel)
            let indexOfMessage = self.messages.count - 1
            let indexPath = IndexPath(row: indexOfMessage, section: 0)
            self.chatTableView.insertRows(at: [indexPath], with: .middle)
            self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }

    }
}