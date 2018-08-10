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
        realm.refresh()
        if let user = realm.objects(UserModel.self).filter("userID = %d", UserDefaults.standard.integer(forKey: Constants.UserDefaults.loggedUserID)).first {
           return user
        }
        return nil
    }
    
    static func userWith(uniqueID: String) -> UserModel? {
        let realm = try! Realm()
        if let user = realm.objects(UserModel.self).filter("uniqueDeviceID = %@", uniqueID).first {
            return user
        }
        return nil
    }
    
    static func userWith(uniqueID: String, andUsername username: String) -> UserModel? {
        let realm = try! Realm()
        realm.refresh()
        if let user = realm.objects(UserModel.self).filter("uniqueDeviceID = %@ AND username = %@", uniqueID, username).first {
            return user
        }
        return nil
    }
    
    static func userWith(username: String, password: String) -> UserModel? {
        let realm = try! Realm()
        if let user = (realm.objects(UserModel.self).filter("username = %@ and password = %@", username, password)).first {
            return user
        }
        return nil
    }
    
    static func registerUser(username: String, password: String) -> Bool {
        let realm = try! Realm()
        guard realm.objects(UserModel.self).filter("username = %@", username).first == nil else {
            return false
        }
        realm.beginWrite()
        let user: UserModel! = UserModel(username: username, password: password)
        user.uniqueDeviceID = (UIDevice.current.identifierForVendor?.uuidString)!.appending(".chat")
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
        let results = realm.objects(MessageModel.self).filter("(sender = %@ AND ANY receivers = %@) OR (sender = %@ AND ANY receivers = %@)", firstUser, secondUser, secondUser, firstUser)
        return results
        
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
        let users = realm.objects(UserModel.self).filter("state != %@", "Offline").filter("state != %@", "Spectre")
        realm.beginWrite()
        users.setValue("Offline", forKey: "state")
        try! realm.commitWrite()
        realm.refresh()
        
    }
    
}
