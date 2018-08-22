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
        let messageModel = MessageModel(withDictionary: dataDict)
        switch messageModel.messageType {
        case MessageType.Message.rawValue:
            self.handleMessageTypeMessage(messageModel: messageModel, peerID: peerID)
        case MessageType.Photo.rawValue:
            self.handleMessageTypePhoto(messageModel: messageModel, peerID: peerID)
        case MessageType.Voice_Record.rawValue:
            self.handleMessageTypeVoiceRecord(messageModel: messageModel, peerID: peerID)
        default:
            break;
        }
    }
    
    func foundChatPeer(peerID: MCPeerID, withDiscoveryInfo info: [String: String]?)  {
        let userState = info!["state"]!
        print(userState)
        let realm = try! Realm()
        var user: UserModel
        if let realmUser = RealmManager.userWith(uniqueID: peerID.displayName, andUsername: info!["username"]!) {
            realm.beginWrite()
                realmUser.state = userState
                realmUser.avatarString = info!["avatar"]!
            try! realm.commitWrite()
            user = realmUser
        }
        else {
            user = UserModel(username: info!["username"]!, state: userState, uniqueDeviceID: peerID.displayName)
            user.avatarString = info!["avatar"]!
            realm.beginWrite()
            realm.add(user)
            try! realm.commitWrite()
        }
        realm.refresh()
        print(user)
        if shouldShowUserDependingOnState(currentUserState: RealmManager.currentLoggedUser()!.state, foundUserState: userState) {
            self.delegate?.didFindNewUser(user: user, peerID: peerID)
        }
        
        //            browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }
    
    private func handleMessageTypeVoiceRecord(messageModel: MessageModel, peerID: MCPeerID) {
        self.handleMessageTypePhoto(messageModel: messageModel, peerID: peerID)
    }
    
    private func handleMessageTypePhoto(messageModel: MessageModel, peerID: MCPeerID) {
        guard let imageData = messageModel.additionalData else {
            return
        }
        var urlToWriteTo = FileManager.getDocumentsDirectory().appendingPathComponent("Limbo", isDirectory: true)
        urlToWriteTo = urlToWriteTo.appendingPathComponent(messageModel.messageString, isDirectory: false)
        try? imageData.write(to: urlToWriteTo)
        let realm = try! Realm()
        realm.beginWrite()
        realm.add(messageModel)
        messageModel.additionalData = nil
        try? realm.commitWrite()
        if let fromPeer = self.getPeerIDForUID(uniqueID: peerID.displayName) {
            let threadSafeMessage = ThreadSafeReference(to: messageModel)
            chatDelegate?.didReceiveMessage(threadSafeMessageRef: threadSafeMessage, fromPeerID: fromPeer)
        }
    }
    
    private func handleMessageTypeMessage(messageModel: MessageModel, peerID: MCPeerID) {
        if (Constants.Curses.allCurses.contains(where: { (curse) -> Bool in
            curse.rawValue == messageModel.messageString
        })) && messageModel.sender?.state == "Ghost" {
            let curse = Curse(rawValue: messageModel.messageString)!
            
            guard let user = RealmManager.currentLoggedUser() else {
                return
            }
            
            let resultOfCurse = CurseManager.applyCurse(curse: curse, toUser: user)
            if resultOfCurse.success {
                UserDefaults.standard.set(peerID.displayName, forKey: Constants.UserDefaults.curseUserUniqueDeviceID)
                UserDefaults.standard.set(messageModel.sender?.username, forKey: Constants.UserDefaults.curseUserUsername)
                chatDelegate!.didReceiveCurse(curse: curse, remainingTime: Constants.Curses.curseTime)
            }
            else {
                let remainingTime = String(Int(Constants.SpecialItems.itemTime) - Int(-resultOfCurse.remainingTime)) + " seconds!"
                NotificationManager.shared.presentItemNotification(withTitle: "Saint's Medallion", andText: "Someone tried to haunt you! But you are protected for " + remainingTime)
                let answerMessage = MessageModel()
                answerMessage.messageString = "I am protected by the Saint's Medallion.\nYou FOOL!"
                answerMessage.sender = user
                answerMessage.receivers.append(messageModel.sender!)
                _ = self.sendMessage(messageModel: answerMessage, toPeerID: peerID)
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
}

