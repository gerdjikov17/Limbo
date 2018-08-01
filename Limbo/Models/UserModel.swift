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
    var curse: Curse = .None
    
    convenience init(username: String, password: String) {
        self.init()
        let realm = try! Realm()
        self.userID = realm.objects(UserModel.self).count
        self.username = username
        self.password = password
    }
    convenience init(username: String, state: String, uniqueDeviceID: String) {
        self.init()
        self.username = username
        self.state = state
        self.uniqueDeviceID = uniqueDeviceID
    }
    
    override class func primaryKey() -> String? {
        return "username"
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
            "username": self.username
            
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
