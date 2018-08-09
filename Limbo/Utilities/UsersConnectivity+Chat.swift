//
//  UsersConnectivity+Chat.swift
//  Limbo
//
//  Created by A-Team User on 8.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import RealmSwift

extension UsersConnectivity {
    
    func handleChatData(data: Data, fromPeer peerID: MCPeerID) {
        let dataDict = NSKeyedUnarchiver.unarchiveObject(with: data) as! Dictionary<String, Any>
        //            let dataDict = try! JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! [String: Any]
        let messageModel = MessageModel(withDictionary: dataDict)
        if (Constants.Curses.allCurses.contains(where: { (curse) -> Bool in
            curse.rawValue == messageModel.messageString
        })) && messageModel.sender?.state == "Ghost" {
            let curse = Curse(rawValue: messageModel.messageString)!
            if let user = RealmManager.currentLoggedUser() {
                let resultOfCurse = CurseManager.applyCurse(curse: curse, toUser: user)
                if resultOfCurse.0 {
                    UserDefaults.standard.set(peerID.displayName, forKey: Constants.UserDefaults.curseUserUniqueDeviceID)
                    chatDelegate!.didReceiveCurse(curse: curse, remainingTime: Constants.Curses.curseTime)
                }
                else {
                    let remainingTime = String(Int(Constants.SpecialItems.itemTime) - Int(-resultOfCurse.1)) + " seconds!"
                    NotificationManager.shared.presentItemNotification(withTitle: "Saint's Medallion", andText: "Someone tried to haunt you! But you are protected for " + remainingTime)
                        let answerMessage = MessageModel()
                        answerMessage.messageString = "I am protected by the Saint's Medallion.\nYou FOOL!"
                        answerMessage.sender = user
                        answerMessage.receivers.append(messageModel.sender!)
                    _ = self.sendMessage(messageModel: answerMessage, toPeerID: peerID)
                }
            }
        }
        else {
            let realm = try! Realm()
            realm.beginWrite()
            realm.add(messageModel)
            try? realm.commitWrite()
            if let fromPeer = self.getPeerIDForUID(uniqueID: peerID.displayName) {
                let threadSafeMessage = ThreadSafeReference(to: messageModel)
                chatDelegate?.didReceiveMessage(threadSafeMessageRef: threadSafeMessage, fromPeerID: fromPeer)
            }
        }
    }
    
    func foundChatPeer(peerID: MCPeerID, withDiscoveryInfo info: [String: String]?)  {
        let userState = info!["state"]!
        let userModel: UserModel! = UserModel(username: info!["username"]!, state: userState, uniqueDeviceID: peerID.displayName)
        userModel.avatarString = info!["avatar"]!
        let realm = try! Realm()
        if let realmUser = realm.objects(UserModel.self).filter("uniqueDeviceID == %@", peerID.displayName).first {
            try? realm.write {
                realmUser.state = userState
            }
        }
        else {
            realm.beginWrite()
            realm.add(userModel)
            try! realm.commitWrite()
            
        }
        realm.refresh()
        if shouldShowUserDependingOnState(foundUserState: userState) {
            self.delegate?.didFindNewUser(user: userModel, peerID: peerID)
        }
        
        //            browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }
}

