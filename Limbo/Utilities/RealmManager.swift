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
        if let user = realm.objects(UserModel.self).filter("userID = %d", UserDefaults.standard.integer(forKey: Constants.UserDefaults.loggedUserID)).first {
           return user
        }
        else {
            return nil
        }
    }
    
    static func userWith(uniqueID: String) -> UserModel? {
        let realm = try! Realm()
        if let user = realm.objects(UserModel.self).filter("uniqueDeviceID = %@", uniqueID).first {
            return user
        }
        else {
            return nil
        }
    }
    
    
}
