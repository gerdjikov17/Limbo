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
    var state = ""
    var avatar: UIImage {
        get {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            var avatarsDirectory: URL = paths[0]
            avatarsDirectory = avatarsDirectory.appendingPathComponent("avatars")
            avatarsDirectory = avatarsDirectory.appendingPathComponent(String(self.userID)).appendingPathExtension("jpg")
            let data = try? Data(contentsOf: avatarsDirectory)
            if let data = data {
                return UIImage(data: data)!
            }
            return UIImage(named: "no_avatar")!
        }
        set {
            let data = UIImageJPEGRepresentation(newValue, 1)
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            var avatarsDirectory: URL = paths[0]
            avatarsDirectory = avatarsDirectory.appendingPathComponent("avatars")
            avatarsDirectory = avatarsDirectory.appendingPathComponent(String(self.userID)).appendingPathExtension("jpg")
            do {
                try data?.write(to: avatarsDirectory)
            } catch {
                print(error.localizedDescription)
            }
            
        }
    }
    
    convenience init(username: String, password: String) {
        self.init()
        let realm = try! Realm()
        self.userID = realm.objects(UserModel.self).count
        self.username = username
        self.password = password
    }
    convenience init(username: String) {
        self.init()
        self.username = username
    }
    
    override class func primaryKey() -> String? {
        return "username"
    }
    
}
