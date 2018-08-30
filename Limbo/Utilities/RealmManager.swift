//
//  RealmManager.swift
//  Limbo
//
//  Created by A-Team User on 2.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit
import RealmSwift

class RealmManager: NSObject {
    static func currentLoggedUser() -> UserModel? {
        let realm = try! Realm()
        return realm.objects(UserModel.self).filter("userID = %d",
                                                    UserDefaults.standard.integer(forKey: Constants.UserDefaults.loggedUserID)).first
    }
    
    static func userWith(uniqueID: String) -> UserModel? {
        let realm = try! Realm()
        return realm.objects(UserModel.self).filter("uniqueDeviceID = %@", uniqueID).first
    }
    
    static func userWith(uniqueID: String, andUsername username: String) -> UserModel? {
        let realm = try! Realm()
        return realm.objects(UserModel.self).filter("uniqueDeviceID = %@ AND username = %@", uniqueID, username).first
    }
    
    static func userWith(username: String, password: String) -> UserModel? {
        let realm = try! Realm()
        return (realm.objects(UserModel.self).filter("username = %@ and password = %@", username, password)).first
    }
    
    static func userWith(compoundKey: String) -> UserModel? {
        let realm = try! Realm()
        return realm.objects(UserModel.self).filter("compoundKey = %@", compoundKey).first
    }
    
    static func registerUser(username: String, password: String) -> Bool {
        let realm = try! Realm()
        guard realm.objects(UserModel.self).filter("username = %@", username).first == nil else {
            return false
        }
        realm.beginWrite()
        let user: UserModel! = UserModel(username: username, password: password)
        user.userID = realm.objects(UserModel.self).count
        realm.add(user)
        try! realm.commitWrite()
        realm.refresh()
        let dict = ["username": username, "date": Date()] as [String : Any]
        UserDefaults.standard.set(dict, forKey: Constants.UserDefaults.gift)
        return true
    }
    
    static func getMessagesForUsers(firstUser: UserModel, secondUser: UserModel) -> Results<MessageModel>? {
        let realm = try! Realm()
        return realm.objects(MessageModel.self)
            .filter("(sender = %@ AND ANY receivers = %@) OR (sender = %@ AND ANY receivers = %@)",
                    firstUser, secondUser, secondUser, firstUser)
        
    }
    
    static func getMessagesForChatRoom(firstUser: UserModel, chatRoom: ChatRoomModel) -> Results<MessageModel>? {
        let realm = try! Realm()
        let resultsUsers = chatRoom.usersChattingWith.filter("userID != %d", 5)
        return realm.objects(MessageModel.self)
            .filter("(sender = %@ AND chatRoomUUID = %@) OR (sender IN %@ AND chatRoomUUID = %@)",
                    firstUser, chatRoom.uuid, resultsUsers, chatRoom.uuid)
        
    }
    
    static func addNewMessage(message: MessageModel) {
        let realm = try! Realm()
        try? realm.write {
            realm.add(message)
        }
    }
    
    static func chatRoom(forUUID uuid: String) -> ChatRoomModel? {
        let realm = try! Realm()
        return realm.objects(ChatRoomModel.self).filter("uuid = %@", uuid).first
    }
    
    static func itemsCountForCurrentUser() -> (candles :Int, medallions: Int) {
        if let user = self.currentLoggedUser() {
            let candles = user.items[SpecialItem.HolyCandle.rawValue]
            let medallions = user.items[SpecialItem.SaintsMedallion.rawValue]
            return(candles!, medallions!)
        }
        return (0, 0)
    }
    
    static func clearUsersStates() {
        let realm = try! Realm()
        let users = realm.objects(UserModel.self)
            .filter("state != %@ AND userID = %d", "Offline", -1)
            .filter("state != %@", "Spectre")
        realm.beginWrite()
        users.setValue("Offline", forKey: "state")
        try! realm.commitWrite()
        realm.refresh()
    }
    
    static func addChatRoom(chatRoom: ChatRoomModel) {
        let realm = try! Realm()
        try? realm.write {
            realm.add(chatRoom)
        }
    }
    
    static func hasChatRoomInRealm(chatRoom: ChatRoomModel) -> Bool {
        let realm = try! Realm()
        return realm.objects(ChatRoomModel.self).filter("uuid = %@", chatRoom.uuid).first != nil
    }
    
}
