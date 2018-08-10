//
//  CurseManager.swift
//  Limbo
//
//  Created by A-Team User on 31.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import RealmSwift
import UserNotifications

class CurseManager: NSObject {
    static func applyCurse(curse: Curse, toUser: UserModel) -> (Bool, Double) {
        if toUser.specialItem == SpecialItem.SaintsMedallion.rawValue {
            if let lastItemDate = toUser.specialItemUsedDate {
                if !lastItemDate.timeIntervalSinceNow.isLess(than: -Constants.Curses.curseTime) {
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
    
    static func reApplyCurse(curse: Curse, toUser: UserModel, remainingTime: Double) {
        let fireAt = Date(timeIntervalSinceNow: remainingTime)
        let timer = Timer.init(fireAt: fireAt, interval: 0, target: self, selector: #selector(removeCurse), userInfo: ["curse": curse, "user": toUser], repeats: false)
        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
    }

    static func applySpecialItem(specialItem: SpecialItem, toUser: UserModel) {
        let realm = try! Realm()
        if specialItem == SpecialItem.SaintsMedallion {
            if toUser.specialItemUsedDate == nil || (toUser.specialItemUsedDate?.timeIntervalSinceNow.isLess(than: -180.0))! {
                
                let medallionCount = toUser.items[specialItem.rawValue]
                if medallionCount! > 0 {
                    let remainingTime = Constants.SpecialItems.itemTime
                    
                    realm.beginWrite()
                    toUser.items[specialItem.rawValue] = medallionCount! - 1
                    toUser.specialItem = specialItem.rawValue
                    toUser.specialItemUsedDate = Date()
                    try? realm.commitWrite()
                    realm.refresh()
                    
                    CurseManager.removeCurse()
                    let fireAt = Date(timeIntervalSinceNow: remainingTime)
                    let timer = Timer.init(fireAt: fireAt, interval: 0, target: self, selector: #selector(removeItem), userInfo: ["item": specialItem, "user": toUser], repeats: false)
                    RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
                    NotificationManager.shared.presentItemNotification(withTitle: "Saint's Medallion", andText: String("You are protected from curses with Saint's Medallion for " + String(Int(remainingTime)) + " seconds"))

                }
                else {
                    NotificationManager.shared.presentItemNotification(withTitle: "Saint's Medallion", andText: "You are out of Saint's Medallions! Hurry up and buy more to stay safe!")
                }
                
                
            }
            else {
                let remainingTime = Constants.SpecialItems.itemTime + (toUser.specialItemUsedDate?.timeIntervalSinceNow)!
                NotificationManager.shared.presentItemNotification(withTitle: "Saint's Medallion", andText: String("You are already protected by Saint's Medallion for " + String(Int(remainingTime)) + " seconds"))
            }
        }
        else {
            if toUser.curse != Curse.None.rawValue {
                let userCandlesCount = toUser.items[SpecialItem.HolyCandle.rawValue]
                if userCandlesCount! > 0 {
                    realm.beginWrite()
                    toUser.items[SpecialItem.HolyCandle.rawValue] = userCandlesCount! - 1
                    try? realm.commitWrite()
                    realm.refresh()
                    NotificationManager.shared.presentItemNotification(withTitle: "Holy Candle", andText: "You removed your curse using holy candle!")
                    CurseManager.removeCurse()
                }
                else {
                    NotificationManager.shared.presentItemNotification(withTitle: "Holy Candle", andText: "You are out of candles, buy more to stay safe!")
                }
                
            }
            else {
                NotificationManager.shared.presentItemNotification(withTitle: "Holy Candle", andText: "You are not cursed")
            }
        }
        
    }
    
    @objc static func removeCurse() {
        
        let realm = try! Realm()
        if let user = RealmManager.currentLoggedUser() {
            if user.curse != "None" {
                print("\nCurse Removed\n")
                try! realm.write {
                    user.curseCastDate = nil
                    user.curse = "None"
                }
                UserDefaults.standard.set(nil, forKey: Constants.UserDefaults.antiCurse)
                UserDefaults.standard.set(nil, forKey: Constants.UserDefaults.curseUserUniqueDeviceID)
                UserDefaults.standard.synchronize()
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
