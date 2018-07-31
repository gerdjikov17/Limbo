//
//  Constants.swift
//  
//
//  Created by A-Team User on 24.07.18.
//

import Foundation

struct Constants {
    static let MCServiceType = "limbo-service"
    
    struct UserDefaults {
        static let isLoged = "UserDefaultsIsLogged"
        static let loggedUserID = "UserDefaultsLoggedUserID"
        static let lastCurse = "UserDefaultsLastCurse"
        static let lastCurseDate = "UserDefaultsLastCurseDate"
        static let curseRemainingTime = "UserDefaultsLastCurseDate"
    }
    
    struct Curses {
        static let allCurses: [Curse] = [.Blind, .Silence, .Posession]
        static let curseTime = 60.0
    }
    
}

enum Curse: String {
    case None
    case Blind
    case Silence
    case Posession
}
