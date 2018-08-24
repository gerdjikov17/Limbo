//
//  NearbyUsersViewController+GroupChats.swift
//  Limbo
//
//  Created by A-Team User on 22.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import Foundation
import UIKit
import MultipeerConnectivity
import RealmSwift

extension NearbyUsersViewController: GroupChatDelegate {
    func addGroupChatCell() {
        guard !(self.chatRooms.keys.contains(where: { (peerID) -> Bool in
            peerID.displayName == "C"
        })) else {
            return
        }
        let groupChatUser = UserModel(username: "Create Group", state: "Group", uniqueDeviceID: "GroupChat")
        groupChatUser.userID = Constants.groupChatAddID
        groupChatUser.avatarString = "group_chat_add_icon.png"
        let addGroopChatRoom = ChatRoomModel()
        addGroopChatRoom.avatar = groupChatUser.avatarString
        addGroopChatRoom.name = groupChatUser.username
        addGroopChatRoom.roomType = RoomType.CreateGroupChat.rawValue
        self.chatRooms[MCPeerID(displayName: "C")]  = (chatRoom: addGroopChatRoom, unreadMessages: 0)
    }
    
    func groupChatCellTap() {
        let allUsersTVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "allUsersTVC") as! AllUsersTableViewController
        allUsersTVC.groupChatDelegate = self
        allUsersTVC.usersChatRooms = self.chatRooms.compactMap({ (arg) -> ChatRoomModel? in
            let (_, value) = arg
            if value.chatRoom.usersChattingWith.count == 1 {
                if value.chatRoom.usersChattingWith.first!.userID == -1 {
                    return value.chatRoom
                }
            }
            return nil
        })
        self.navigationController?.pushViewController(allUsersTVC, animated: true)
    }
    
    func createGroupChat(withChatRooms chatRooms: [ChatRoomModel]) {
        let chatRoom = ChatRoomModel()
        chatRoom.name = "Unnamed group"
        chatRoom.uuid.append(RealmManager.currentLoggedUser()!.uniqueDeviceID + RealmManager.currentLoggedUser()!.username + "-")
        for room in chatRooms {
            chatRoom.usersChattingWith.append(room.usersChattingWith.first!)
            chatRoom.usersPeerIDs.append(room.usersPeerIDs.first!)
            chatRoom.uuid.append(room.usersChattingWith.first!.compoundKey + "§")
        }
        chatRoom.uuid.removeLast()
        chatRoom.roomType = RoomType.GroupChat.rawValue
        
        let usersDict = chatRoom.usersDictionary()
        chatRoom.uuid = ""
        for key in usersDict.keys {
            chatRoom.uuid.append(key+usersDict[key]! + "§")
        }
        chatRoom.uuid.removeLast()
        let realm = try! Realm()
        if let alreadyExistingChatRoom = realm.objects(ChatRoomModel.self).filter("uuid = %@", chatRoom.uuid).first {
            try! realm.write {
                realm.delete(alreadyExistingChatRoom)
            }
        }
        try! realm.write {
            realm.add(chatRoom)
        }
        
        let systemMessage = MessageModel()
        systemMessage.messageType = MessageType.System.rawValue
        systemMessage.messageString = SystemMessage.NewGroupCreated.rawValue
        systemMessage.additionalData = NSKeyedArchiver.archivedData(withRootObject: usersDict)
        systemMessage.sender = self.currentUser
        systemMessage.chatRoomUUID = chatRoom.uuid
        for room in chatRooms {
            if let peerID = self.usersConnectivity.getPeerIDForUID(uniqueID: (room.usersPeerIDs.first)!) {
                _ = self.usersConnectivity.sendMessage(messageModel: systemMessage, toPeerID: peerID)
            }
        }
        
        self.chatRooms[MCPeerID(displayName: "Unnamed group")] = (chatRoom, 0)
        self.nearbyUsersCollectionView.reloadData()
    }
    
    func showGroupChats() {
        guard !(self.chatRooms.keys.contains(where: { (peerID) -> Bool in
            peerID.displayName == "Unnamed group"
        })) else {
            return
        }
        let realm = try! Realm()
        let realmChatRooms = realm.objects(ChatRoomModel.self).filter("usersChattingWith.@count > %d", 1)
        for chatRoom in realmChatRooms {
            self.chatRooms[MCPeerID(displayName: "Unnamed group")] = (chatRoom, 0)
        }
        self.nearbyUsersCollectionView.reloadData()
    }
    
    func didFindNewChatRoom(chatRoomThreadSafeReference: ThreadSafeReference<ChatRoomModel>) {
        DispatchQueue.main.async {
            let realm = try! Realm()
            let chatRoom = realm.resolve(chatRoomThreadSafeReference)
            self.chatRooms[MCPeerID(displayName: "Unnamed group")] = (chatRoom!, 0)
            self.nearbyUsersCollectionView.reloadData()
        }
        
    }
}
