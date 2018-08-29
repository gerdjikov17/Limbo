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
    
}
