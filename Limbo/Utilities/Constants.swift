//
//  Constants.swift
//  
//
//  Created by A-Team User on 24.07.18.
//

import Foundation

struct Constants {
    static let MCServiceType = "tic-tac-toe"
    
    static let groupChatAddID = -10
    
    struct UserDefaults {
        static let isLoged = "UserDefaultsIsLogged"
        static let loggedUserID = "UserDefaultsLoggedUserID"
        static let antiCurse = "UserDefaultsAntiCurse"
        static let curseUserUniqueDeviceID = "UserDefaultsCurseUserUniqueDeviceID"
        static let curseUserUsername = "UserDefaultsCurseUserUsername"
        static let gift = "UserDefaultsGift"
    }
    
    struct Curses {
        static let allCurses: [Curse] = [.Blind, .Silence, .Posession]
        static let curseTime = 60.0
    }
    
    struct SpecialItems {
        static let allSpecialItems: [SpecialItem] = [.HolyCandle, .SaintsMedallion]
        static let itemTime = 180.0
    }
    
    struct Notifications {
        struct Identifiers {
            static let Message = "NotificationIdentifierMessage"
            static let Curse = "NotificationIdentifierCurse"
            static let Item = "NotificationIdentifierItem"
            static let MessageActionReply = "NotificationIdentifierMessage"
            static let CurseActionItemCandle = "NotificationIdentifierCurseActionItemCandle"
            static let CurseActionItemMedallion = "NotificationIdentifierCurseActionItemMedallion"
        }
        
    }
    
}

enum Curse: String {
    case None
    case Blind
    case Silence
    case Posession
}

enum SpecialItem: String {
    case None
    case HolyCandle
    case SaintsMedallion
}

enum MessageType: Int {
    case Message = 0
    case Photo = 1
    case Message_Photo = 2
    case Voice_Record = 3
    case System = 4
}
