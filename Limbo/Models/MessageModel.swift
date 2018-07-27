//
//  MessageModel.swift
//  Limbo
//
//  Created by A-Team User on 25.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import Foundation
import RealmSwift

class MessageModel: Object {
    @objc dynamic var messageString = ""
    @objc dynamic var timeSent = Date()
    @objc dynamic var sender: UserModel?
    let receivers = List<UserModel>()
    
    func toDictionary() -> Dictionary<String, Any> {
        let jsonDict = [
            "messageString": self.messageString,
            "timeSent": self.timeSent,
            "sender": self.sender?.toJSONDict() as Any
            ] as [String : Any]
        return jsonDict
    }
    
    convenience init(withDictionary dictionary: Dictionary<String, Any>) {
        self.init()
        self.messageString = dictionary["messageString"] as! String
        self.timeSent = dictionary["timeSent"] as! Date
        let realm = try! Realm()
        let senderDict: Dictionary = dictionary["sender"] as! Dictionary<String, Any>
        if let username = senderDict["username"] {
            self.sender = realm.objects(UserModel.self).filter("userID == %d AND username == %@", -1, username as! String).first
            self.receivers.append(realm.objects(UserModel.self).filter("userID == %d", UserDefaults.standard.integer(forKey: Constants.UserDefaults.loggedUserID)).first!)
        }
    }
}
