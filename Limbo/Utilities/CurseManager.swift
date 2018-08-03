//
//  CurseManager.swift
//  Limbo
//
//  Created by A-Team User on 31.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class CurseManager: NSObject {
    static func applyCurse(curse: Curse, toUser: UserModel) -> (Bool, Double) {
        if toUser.specialItem == SpecialItem.SaintsMedallion.rawValue {
            if let lastItemDate = toUser.specialItemUsedDate {
                if !lastItemDate.timeIntervalSinceNow.isLess(than: -180.0) {
                    return (false, lastItemDate.timeIntervalSinceNow)
                }
            }
        }
        let remainingTime = Constants.Curses.curseTime
        let realm = try! Realm()
        try! realm.write {
            toUser.curse = curse.rawValue
            toUser.curseCastDate = Date()
            toUser.specialItemUsedDate = nil
            toUser.specialItem = Curse.None.rawValue
        }
        let fireAt = Date(timeIntervalSinceNow: remainingTime)
        let timer = Timer.init(fireAt: fireAt, interval: 0, target: self, selector: #selector(removeCurse), userInfo: ["curse": curse, "user": toUser], repeats: false)
        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
        NotificationManager.shared.presentCurseNotification(withTitle: "You have been cursed", andText: String(curse.rawValue + " for \(Int(remainingTime)) seconds"))
        return (true, remainingTime)
}

    static func applySpecialItem(specialItem: SpecialItem, toUser: UserModel) {
        let remainingTime = Constants.SpecialItems.itemTime
        
        let realm = try! Realm()
        realm.beginWrite()
        toUser.specialItem = specialItem.rawValue
        toUser.specialItemUsedDate = Date()
        toUser.curse = Curse.None.rawValue
        toUser.curseCastDate = nil
        try? realm.commitWrite()
        realm.refresh()
        
        let fireAt = Date(timeIntervalSinceNow: remainingTime)
        let timer = Timer.init(fireAt: fireAt, interval: 0, target: self, selector: #selector(removeItem), userInfo: ["item": specialItem, "user": toUser], repeats: false)
        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
        NotificationManager.shared.presentItemNotification(withTitle: "Saint's Medallion", andText: String("You are protected from curses with Saint's Medallion for " + String(Int(remainingTime)) + " seconds"))
    }
    
    @objc static func removeCurse() {
        let realm = try! Realm()
        if let user = RealmManager.currentLoggedUser() {
            try! realm.write {
                user.curseCastDate = nil
                user.curse = "None"
            }
        }
    }
    
    @objc static func removeItem() {
        let realm = try! Realm()
        if let user = RealmManager.currentLoggedUser() {
            try! realm.write {
                user.specialItemUsedDate = nil
                user.specialItem = "None"
            }
        }
    }
}
