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
    
    static var realm: Realm = try! Realm()
    
//    static let url = FileManager.getDocumentsDirectory().appendingPathComponent("newRealm")
//    static let realmConfig = Realm.Configuration(fileURL: url, inMemoryIdentifier: "asd", syncConfiguration: nil, encryptionKey: nil, readOnly: false, schemaVersion: 1, migrationBlock: nil, deleteRealmIfMigrationNeeded: false, shouldCompactOnLaunch: nil, objectTypes: nil)
//    static var realm: Realm = try! Realm(configuration: realmConfig)
    
    static func userWithPredicate(predicate: NSPredicate) -> UserModel? {
        return realm.objects(UserModel.self).filter(predicate).first
    }
    
    static func currentLoggedUser() -> UserModel? {
        let predicate = NSPredicate(format: "userID = %d",
                                    UserDefaults.standard.integer(forKey: Constants.UserDefaults.loggedUserID))
        return userWithPredicate(predicate: predicate)
    }
    
    static func userWith(uniqueID: String) -> UserModel? {
        let predicate = NSPredicate(format: "uniqueDeviceID = %@", uniqueID)
        return userWithPredicate(predicate: predicate)
    }
    
    static func userWith(uniqueID: String, andUsername username: String) -> UserModel? {
        let predicate = NSPredicate(format: "uniqueDeviceID = %@ AND username = %@", uniqueID, username)
        return userWithPredicate(predicate: predicate)
    }
    
    static func userWith(username: String, password: String) -> UserModel? {
        let predicate = NSPredicate(format: "username = %@ and password = %@", username, password)
        return userWithPredicate(predicate: predicate)
    }
    
    static func userWith(compoundKey: String) -> UserModel? {
        let predicate = NSPredicate(format: "compoundKey = %@", compoundKey)
        return userWithPredicate(predicate: predicate)
    }
    
    static func registerUser(username: String, password: String) -> Bool {
        let usernamePredicate = NSPredicate(format: "username = %@", username)
        
        guard userWithPredicate(predicate: usernamePredicate) == nil else { return false }
        
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
        return realm.objects(MessageModel.self)
            .filter("(sender = %@ AND ANY receivers = %@) OR (sender = %@ AND ANY receivers = %@)",
                    firstUser, secondUser, secondUser, firstUser)
        
    }
    
    static func getMessagesForChatRoom(firstUser: UserModel, chatRoom: ChatRoomModel) -> Results<MessageModel>? {
        let resultsUsers = chatRoom.usersChattingWith.filter("userID != %d", 5)
        return realm.objects(MessageModel.self)
            .filter("(sender = %@ AND chatRoomUUID = %@) OR (sender IN %@ AND chatRoomUUID = %@)",
                    firstUser, chatRoom.uuid, resultsUsers, chatRoom.uuid)
        
    }
    
    static func addNewMessage(message: MessageModel) {
        try? realm.write {
            realm.add(message)
        }
        realm.refresh()
    }
    
    static func chatRoom(forUUID uuid: String) -> ChatRoomModel? {
        return realm.objects(ChatRoomModel.self).filter("uuid = %@", uuid).first
    }
    
    static func itemsCountForCurrentUser() -> (candles :Int, medallions: Int) {
        guard let user = self.currentLoggedUser() else { return(0, 0) }
        
        let candles = user.items[SpecialItem.HolyCandle.rawValue]
        let medallions = user.items[SpecialItem.SaintsMedallion.rawValue]
        return(candles!, medallions!)
    }
    
    static func clearUsersStates() {
        let users = realm.objects(UserModel.self)
            .filter("state != %@ AND userID = %d", "Offline", -1)
            .filter("state != %@", "Spectre")
        realm.beginWrite()
        users.setValue("Offline", forKey: "state")
        try! realm.commitWrite()
        realm.refresh()
    }
    
    static func addChatRoom(chatRoom: ChatRoomModel) {
        try? realm.write {
            realm.add(chatRoom)
        }
    }
    
    static func hasChatRoomInRealm(chatRoom: ChatRoomModel) -> Bool {
        return realm.objects(ChatRoomModel.self).filter("uuid = %@", chatRoom.uuid).first != nil
    }
    
    static func getImagesFromMessageHistory(messageHistory: Results<MessageModel>) -> [(image: UIImage, sender: String?)] {
        var images_senders: [(image: UIImage, sender: String?)] = Array()
        let limboDirectory = FileManager.getDocumentsDirectory().appendingPathComponent("Limbo", isDirectory: false)
        for message in messageHistory {
            if let image = ImageCache.shared.getImage(forKey: (message.messageString as NSString)) {
                images_senders.append((image: image, sender: message.sender?.username))
                print("gets data from the cache")
            }
            else {
                let filePath = limboDirectory.appendingPathComponent(message.messageString, isDirectory: false)
                guard let imageData = try? Data(contentsOf: filePath) else { continue }
                guard let image = UIImage(data: imageData) else { continue }
                ImageCache.shared.cacheImage(image: image, forKey: (message.messageString as NSString))
                images_senders.append((image: image, sender: message.sender?.username))
            }
        }
        return images_senders
    }
    
    static func getMessagesWithImages(forMessageHistory messageHistory: Results<MessageModel>) -> Results<MessageModel> {
        return messageHistory.filter("messageType = %d", MessageType.Photo.rawValue)
    }
    
}
