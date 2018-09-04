//
//  ChatRoomModel.swift
//  Limbo
//
//  Created by A-Team User on 22.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit
import RealmSwift
import MultipeerConnectivity

class ChatRoomModel: Object {
    @objc dynamic var uuid = ""
    @objc dynamic var name = ""
    @objc dynamic var avatar = "ghost_avatar.png"
    @objc dynamic var roomType = RoomType.SingleUserChat.rawValue
    let usersChattingWith = List<UserModel>()
    var usersPeerIDs = List<String>()
    
    func setRoomType(roomType: RoomType) {
        let realm = try! Realm()
        try? realm.write {
            self.roomType = roomType.rawValue
        }
    }
    
    func usersDictionary() -> [String: String] {
        var dict: [String: String] = Dictionary()
        dict[RealmManager.currentLoggedUser()!.uniqueDeviceID] = RealmManager.currentLoggedUser()!.username
        for user in usersChattingWith {
            dict[user.uniqueDeviceID] = user.username
        }
        return dict
    }
    
    convenience init(withUsers users: [UserModel]) {
        self.init()
        self.name = "Unnamed group"
        self.uuid.append(RealmManager.currentLoggedUser()!.uniqueDeviceID +
            RealmManager.currentLoggedUser()!.username +
            Constants.chatRoomSeparator)
        for user in users {
            self.usersChattingWith.append(user)
            self.usersPeerIDs.append(user.compoundKey)
            self.uuid.append(user.compoundKey + Constants.chatRoomSeparator)
        }
        self.uuid.removeLast()
        self.roomType = RoomType.GroupChat.rawValue
        
        let usersDict = self.usersDictionary()
        self.uuid = ""
        for key in usersDict.keys {
            self.uuid.append(key+usersDict[key]! + Constants.chatRoomSeparator)
        }
        self.uuid.removeLast()
    }
    
    convenience init(uuid: String) {
        self.init()
        self.name = "Unnamed group"
        for compoundKey in uuid.components(separatedBy: Constants.chatRoomSeparator) {
            if compoundKey != RealmManager.currentLoggedUser()?.compoundKey {
                self.usersChattingWith.append(RealmManager.userWith(compoundKey: compoundKey)!)
            }
        }
        self.uuid = uuid
        self.roomType = RoomType.GroupChat.rawValue
    }
    
    convenience init(user: UserModel, gameType: Int, peerIDString: String) {
        self.init()
        self.name = user.username
        self.uuid = user.compoundKey
        self.avatar = user.avatarString
        self.usersChattingWith.append(user)
        self.roomType = gameType
        self.usersPeerIDs.append(peerIDString)
    }
    
    func changeAvatar(newAvatar: String) {
        let realm = try! Realm()
        try! realm.write {
            self.avatar = newAvatar
        }
    }
    
}
