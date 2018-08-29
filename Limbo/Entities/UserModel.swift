//
//  UserModel.swift
//  Limbo
//
//  Created by A-Team User on 24.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import Foundation
import UIKit
import Realm
import RealmSwift

class UserModel: Object {
    @objc dynamic var userID = -1
    @objc dynamic var username = ""
    @objc dynamic var password = ""
    @objc dynamic var avatarString = "ghost_avatar.png"
    @objc dynamic var state = ""
    @objc dynamic var uniqueDeviceID = ""
    @objc dynamic var curse = "None"
    @objc dynamic var curseCastDate: Date? = nil
    @objc dynamic var specialItem = "None"
    @objc dynamic var specialItemUsedDate: Date? = nil
    @objc dynamic var itemsData: Data?
    @objc dynamic var compoundKey = ""
    var items: [String: Int] {
        get {
            guard let itemsData = itemsData else {
                return [String: Int]()
            }
            do {
                let dict = try JSONSerialization.jsonObject(with: itemsData, options: []) as? [String: Int]
                return dict!
            } catch {
                return [String: Int]()
            }
        }
        
        set {
            do {
                let data = try JSONSerialization.data(withJSONObject: newValue, options: [])
                itemsData = data
            } catch {
                itemsData = nil
            }
        }
    }
    
    convenience init(username: String, state: String, uniqueDeviceID: String) {
        self.init()
        self.username = username
        self.state = state
        self.uniqueDeviceID = uniqueDeviceID
        self.compoundKey = uniqueDeviceID + username
    }
    
    convenience init(username: String, password: String) {
        self.init()
        self.username = username
        self.password = password
        self.uniqueDeviceID = (UIDevice.current.identifierForVendor?.uuidString)!.appending(".chat")
        self.compoundKey = self.uniqueDeviceID + username
        self.items = [SpecialItem.HolyCandle.rawValue: 5, SpecialItem.SaintsMedallion.rawValue: 5]
    }
    
    override class func primaryKey() -> String? {
        return "compoundKey"
    }
    
    func setState(batteryLevel: Float) {
        let batteryLevel = batteryLevel * 100
        var state: String
        state = "Ghost"
        if batteryLevel > 5 {
            state = "Undead"
            if batteryLevel > 10 {
                state = "Hollow"
                if batteryLevel > 25 {
                    state = "Dying"
                    if batteryLevel > 50 {
                        state = "Human"
                    }
                }
            }
        }
        let realm = try! Realm()
        realm.beginWrite()
        self.state = state;
        try! realm.commitWrite()
    }
    
    func toJSONDict() -> Dictionary<String, Any> {
        let jsonDict = [
            "userID": self.userID,
            "username": self.username,
            "uniqueDeviceID": self.uniqueDeviceID
            
        ] as [String: Any]
        return jsonDict
    }
    
    func changeAvatar(newImageString: String) {
        let realm = try! Realm()
        try! realm.write {
            self.avatarString = newImageString
        }
    }
    
}
