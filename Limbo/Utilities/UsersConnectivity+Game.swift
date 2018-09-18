//
//  UsersConnectivity+Game.swift
//  Limbo
//
//  Created by A-Team User on 8.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import RealmSwift

extension UsersConnectivity {
    
    func handleGameData(data: Data, fromPeer peerID: MCPeerID) {
        let dictWithData = try! JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! [String: Any]
        
        let message = dictWithData.first?.value as! String
        let user = RealmManager.userWith(uniqueID: peerID.displayName)
        let chatRoom = RealmManager.chatRoom(forUUID: user!.compoundKey)
        
        let messageModel = MessageModel(messageString: message, sender: user!, chatRoom: chatRoom!)
        RealmManager.addNewMessage(message: messageModel)
        
        print(messageModel)
        
        guard let fromPeer = self.getPeerIDForUID(uniqueID: peerID.displayName) else { return }
        
        let threadSafeMessage = ThreadSafeReference(to: messageModel)
        chatDelegate?.didReceiveMessage(threadSafeMessageRef: threadSafeMessage, fromPeerID: fromPeer)
        
    }
    
    func foundGamePeer(peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print(info as Any)
        print(peerID)
        let username = String(peerID.displayName.prefix(upTo:
                                    peerID.displayName.index(peerID.displayName.startIndex,
                                     offsetBy: peerID.displayName.count - 5)))
        
        var user: UserModel
        var chatRoom: ChatRoomModel
        
        let gameType = self.gameType(forGameName: info!["gameName"]!)
        
        let realm = try! Realm()
        if let realmUser = RealmManager.userWith(uniqueID: peerID.displayName) {
            if let chatRoom = RealmManager.chatRoom(forUUID: realmUser.compoundKey) {
                try! realm.write {
                    chatRoom.roomType = gameType
                    realmUser.state = info!["gameName"]!
                }
            } else {
                chatRoom = ChatRoomModel(user: realmUser, gameType: gameType, peerIDString: peerID.displayName)
                RealmManager.addChatRoom(chatRoom: chatRoom)
            }
            
            user = realmUser
            
        }
        else {
            user = UserModel(username: username, state: info!["gameName"]!, uniqueDeviceID: peerID.displayName)
            user.userID = -3
            
            realm.beginWrite()
            realm.add(user)
            try! realm.commitWrite()
            
            chatRoom = ChatRoomModel(user: user, gameType: gameType, peerIDString: peerID.displayName)
            RealmManager.addChatRoom(chatRoom: chatRoom)
            
        }
        realm.refresh()
        self.delegate?.didFindNewUser(user: user, peerID: peerID)
    }
    
    private func gameType(forGameName: String) -> Int {
        if forGameName == "Tic-Tac-Toe" {
            return RoomType.Tic_Tac_Toe.rawValue
        } else {
            return RoomType.Tunak_Tunak.rawValue
        }
    }
}
