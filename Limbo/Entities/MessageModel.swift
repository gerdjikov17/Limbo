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
    @objc dynamic var messageType = 1
    @objc dynamic var additionalData: Data?
    @objc dynamic var timeSent = Date()
    @objc dynamic var sender: UserModel?
    @objc dynamic var chatRoomUUID = ""
    
    func toDictionary() -> Dictionary<String, Any> {
        let jsonDict = [
            "messageString": self.messageString,
            "messageType": self.messageType,
            "additionalData": self.additionalData as Any,
            "timeSent": self.timeSent,
            "sender": self.sender?.toJSONDict() as Any,
            "chatRoomUUID": self.chatRoomUUID
            ] as [String : Any]
        return jsonDict
    }
    
    convenience init(withDictionary dictionary: Dictionary<String, Any>) {
        self.init()
        self.messageString = dictionary["messageString"] as! String
        self.messageType = dictionary["messageType"] as! Int
        if let additionalData = dictionary["additionalData"] {
            self.additionalData = additionalData as? Data
        }
        self.timeSent = dictionary["timeSent"] as! Date
        let senderDict: Dictionary = dictionary["sender"] as! Dictionary<String, Any>
        if let uniqueDeviceID = senderDict["uniqueDeviceID"] {
            self.sender = RealmManager.userWith(uniqueID: uniqueDeviceID as! String,
                                                andUsername: senderDict["username"] as! String)
            
        }
        let uuid = dictionary["chatRoomUUID"] as! String
        self.chatRoomUUID = uuid
    }
    
    convenience init(withType messageType: MessageType) {
        self.init()
        self.setMessageType(messageType: messageType)
    }
    
    convenience init(uuid: String, sender: UserModel) {
        self.init()
        self.messageType = MessageType.System.rawValue
        self.messageString = SystemMessage.NewGroupCreated.rawValue
        self.additionalData = NSKeyedArchiver.archivedData(withRootObject: uuid)
        self.sender = sender
        self.chatRoomUUID = uuid
    }
    
    func setMessageType(messageType: MessageType) {
        let realm = try! Realm()
        realm.beginWrite()
        self.messageType = messageType.rawValue
        try! realm.commitWrite()
    }
}
