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
        let messageModel = MessageModel()
        messageModel.messageString = dictWithData.first?.value as! String
        messageModel.sender = RealmManager.userWith(uniqueID: peerID.displayName)
//        messageModel.receivers.append(RealmManager.currentLoggedUser()!)
//        messageModel.chatRoom = RealmManager.chatRoom(forUUID: messageModel.sender!.compoundKey)
        messageModel.chatRoomUUID = messageModel.sender!.compoundKey
        let realm = try! Realm()
        realm.beginWrite()
        realm.add(messageModel)
        try? realm.commitWrite()
        if let fromPeer = self.getPeerIDForUID(uniqueID: peerID.displayName) {
            let threadSafeMessage = ThreadSafeReference(to: messageModel)
            chatDelegate?.didReceiveMessage(threadSafeMessageRef: threadSafeMessage, fromPeerID: fromPeer)
        }
        
        print(messageModel)
    }
    
    func foundGamePeer(peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print(info as Any)
        print(peerID)
        let username = String(peerID.displayName.prefix(upTo: peerID.displayName.index(peerID.displayName.startIndex, offsetBy: peerID.displayName.count - 5)))
        var user: UserModel
        let realm = try! Realm()
        if let realmUser = RealmManager.userWith(uniqueID: peerID.displayName) {
            try! realm.write {
                realmUser.state = info!["gameName"]!
            }
            user = realmUser
        }
        else {
            user = UserModel(username: username, state: info!["gameName"]!, uniqueDeviceID: peerID.displayName)
            user.userID = -3
            realm.beginWrite()
            realm.add(user)
            try! realm.commitWrite()
        }
        let chatRoom = ChatRoomModel()
        chatRoom.name = user.username
        chatRoom.uuid = user.compoundKey
        chatRoom.avatar = user.avatarString
        chatRoom.usersChattingWith.append(user)
        chatRoom.roomType = RoomType.SingleUserChat.rawValue
        chatRoom.usersPeerIDs.append(peerID.displayName)
        try! realm.write {
            realm.add(chatRoom)
        }
        realm.refresh()
        self.delegate?.didFindNewUser(user: user, peerID: peerID)
    }
}
