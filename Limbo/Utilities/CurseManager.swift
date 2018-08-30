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
    static func applyCurse(curse: Curse, toUser: UserModel) -> (success: Bool, remainingTime: Double) {
        if toUser.specialItem == SpecialItem.SaintsMedallion.rawValue, let lastItemDate = toUser.specialItemUsedDate {
            if !lastItemDate.timeIntervalSinceNow.isLess(than: -Constants.Curses.curseTime) {
                return (false, lastItemDate.timeIntervalSinceNow)
            }
        }
        let remainingTime = Constants.Curses.curseTime
        
        toUser.setCurse(curse: curse)
        
        let fireAt = Date(timeIntervalSinceNow: remainingTime)
        let timer = Timer.init(fireAt: fireAt, interval: 0, target: self,
                               selector: #selector(removeCurse),
                               userInfo: ["curse": curse, "user": toUser], repeats: false)
        
        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
        
        NotificationManager.shared.presentCurseNotification(withTitle: "You have been cursed",
                                                            andText: String(curse.rawValue + " for \(Int(remainingTime)) seconds"))
        
        return (true, remainingTime)
    }
    
    static func reApplyCurse(curse: Curse, toUser: UserModel, remainingTime: Double) {
        let fireAt = Date(timeIntervalSinceNow: remainingTime)
        let timer = Timer.init(fireAt: fireAt, interval: 0, target: self,
                               selector: #selector(removeCurse),
                               userInfo: ["curse": curse, "user": toUser], repeats: false)
        
        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
    }

    static func applySpecialItem(specialItem: SpecialItem, toUser: UserModel) {
        if specialItem == SpecialItem.SaintsMedallion {
            self.applySaintsMedallion(toUser: toUser, specialItem: specialItem)
        } else if specialItem == SpecialItem.HolyCandle {
            self.applyHolyCandle(toUser: toUser, specialItem: specialItem)
        }
    }
    
    @objc static func removeCurse() {
        
        let realm = try! Realm()
        
        guard let user = RealmManager.currentLoggedUser() else {
            return
        }
        
        guard user.curse != "None" else {
            return
        }
        
        print("\nCurse Removed\n")
        try! realm.write {
            user.curseCastDate = nil
            user.curse = "None"
        }
        UserDefaults.standard.set(nil, forKey: Constants.UserDefaults.antiCurse)
        UserDefaults.standard.set(nil, forKey: Constants.UserDefaults.curseUserUniqueDeviceID)
        UserDefaults.standard.synchronize()
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
    
    private static func applySaintsMedallion(toUser: UserModel, specialItem: SpecialItem) {
        guard toUser.specialItemUsedDate == nil || (toUser.specialItemUsedDate?.timeIntervalSinceNow.isLess(than: -Constants.Curses.curseTime))! else {
            
            let remainingTime = Constants.SpecialItems.itemTime + (toUser.specialItemUsedDate?.timeIntervalSinceNow)!
            
            let notificationText = String("You are already protected by Saint's Medallion for " +
                String(Int(remainingTime)) + " seconds")
            
            NotificationManager.shared.presentItemNotification(withTitle: "Saint's Medallion",
                                                               andText: notificationText)
            return
            
        }
        
        let medallionCount = toUser.items[specialItem.rawValue]
        
        guard medallionCount! > 0 else {
            
            NotificationManager.shared.presentItemNotification(withTitle: "Saint's Medallion",
                                                               andText: "You are out of Saint's Medallions! Hurry up and buy more to stay safe!")
            return
        }
        
        let remainingTime = Constants.SpecialItems.itemTime
        
        toUser.decrementSpecialItem(specialItem: specialItem)
        
        CurseManager.removeCurse()
        let fireAt = Date(timeIntervalSinceNow: remainingTime)
        let timer = Timer.init(fireAt: fireAt, interval: 0,
                               target: self, selector: #selector(removeItem),
                               userInfo: ["item": specialItem, "user": toUser], repeats: false)
        
        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
        
        let notificationText = String("You are protected from curses with Saint's Medallion for " +
            String(Int(remainingTime)) + " seconds")
        
        NotificationManager.shared.presentItemNotification(withTitle: "Saint's Medallion",
                                                           andText: notificationText)
    }
    
    private static func applyHolyCandle(toUser: UserModel, specialItem: SpecialItem) {
        guard toUser.curse != Curse.None.rawValue else {
            NotificationManager.shared.presentItemNotification(withTitle: "Holy Candle",
                                                               andText: "You are not cursed")
            return
        }
        let userCandlesCount = toUser.items[SpecialItem.HolyCandle.rawValue]
        guard userCandlesCount! > 0 else {
            NotificationManager.shared.presentItemNotification(withTitle: "Holy Candle",
                                                               andText: "You are out of candles, buy more to stay safe!")
            return
        }
        
        toUser.decrementSpecialItem(specialItem: specialItem)
        
        NotificationManager.shared.presentItemNotification(withTitle: "Holy Candle",
                                                           andText: "You removed your curse using holy candle!")
        CurseManager.removeCurse()
    }
}
