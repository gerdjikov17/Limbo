//
//  CurseManager.swift
//  Limbo
//
//  Created by A-Team User on 31.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit

class CurseManager: NSObject {
    static func applyCurse(curse: Curse, toUser: UserModel) {
        UserDefaults.standard.set(curse.rawValue, forKey: Constants.UserDefaults.lastCurse)
        UserDefaults.standard.set(Date(), forKey: Constants.UserDefaults.lastCurseDate)
        UserDefaults.standard.synchronize()
        toUser.curse = curse
        let fireAt = Date(timeIntervalSinceNow: Constants.Curses.curseTime)
        let timer = Timer.init(fireAt: fireAt, interval: 0, target: self, selector: #selector(removeCurse(timer:)), userInfo: ["curse": curse, "user": toUser], repeats: false)
        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
    }
    
    static func reApplyCurse(curse: Curse, toUser: UserModel, remainingTime: TimeInterval) {
        UserDefaults.standard.set(curse.rawValue, forKey: Constants.UserDefaults.lastCurse)
        UserDefaults.standard.set(Date(), forKey: Constants.UserDefaults.lastCurseDate)
        UserDefaults.standard.synchronize()
        toUser.curse = curse
        let fireAt = Date(timeIntervalSinceNow: remainingTime)
        let timer = Timer.init(fireAt: fireAt, interval: 0, target: self, selector: #selector(removeCurse(timer:)), userInfo: ["curse": curse, "user": toUser], repeats: false)
        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
    }
    
    @objc static func removeCurse(timer: Timer) {
        UserDefaults.standard.set("", forKey: Constants.UserDefaults.lastCurse)
        let userInfo = timer.userInfo as! [String: AnyObject]
        let user = userInfo["user"] as! UserModel
        user.curse = .None
    }
}
