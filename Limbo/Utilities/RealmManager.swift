//
//  RealmManager.swift
//  Limbo
//
//  Created by A-Team User on 2.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit
import CommonCrypto
import RealmSwift

class RealmManager: NSObject {
    
    static var realm: Realm = try! Realm()
    
//    static let url = FileManager.getDocumentsDirectory().appendingPathComponent("newRealm")
//    static let realmConfig = Realm.Configuration(fileURL: url, inMemoryIdentifier: "asd", syncConfiguration: nil, encryptionKey: nil, readOnly: false, schemaVersion: 1, migrationBlock: nil, deleteRealmIfMigrationNeeded: false, shouldCompactOnLaunch: nil, objectTypes: nil)
//    static var realm: Realm = try! Realm(configuration: realmConfig)
    
    class func passwordHash(password: String) -> String {
         if let strData = password.data(using: String.Encoding.utf8) {
             /// #define CC_SHA256_DIGEST_LENGTH     32
             /// Creates an array of unsigned 8 bit integers that contains 32 zeros
             var digest = [UInt8](repeating: 0, count:Int(CC_SHA256_DIGEST_LENGTH))
      
             /// CC_SHA256 performs digest calculation and places the result in the caller-supplied buffer for digest (md)
             /// Takes the strData referenced value (const unsigned char *d) and hashes it into a reference to the digest parameter.
             strData.withUnsafeBytes {
                 // CommonCrypto
                 // extern unsigned char *CC_SHA256(const void *data, CC_LONG len, unsigned char *md)  -|
                 // OpenSSL                                                                             |
                 // unsigned char *SHA256(const unsigned char *d, size_t n, unsigned char *md)        <-|
                 CC_SHA256($0.baseAddress, UInt32(strData.count), &digest)
             }
      
             var sha256String = ""
             /// Unpack each byte in the digest array and add them to the sha256String
             for byte in digest {
                 sha256String += String(format:"%02x", UInt8(byte))
            }
             return sha256String
         }
         return ""
    }
    
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
        let hashedPassword = passwordHash(password: password)
        print(hashedPassword)
        let predicate = NSPredicate(format: "username = %@ and password = %@", username, hashedPassword)
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
        let hashedPassword = passwordHash(password: password)
        print(hashedPassword)
        let user: UserModel! = UserModel(username: username, password: hashedPassword)
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
