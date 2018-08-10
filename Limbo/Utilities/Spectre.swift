//
//  Spectre.swift
//  Limbo
//
//  Created by A-Team User on 1.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import RealmSwift
import MultipeerConnectivity

class Spectre: NSObject {
    
    fileprivate enum Separator: String {
        case none = ""
        case space = " "
        case dot = "."
        case newLine = "\n"
    }
    
    //    MARK: Properties
    
    static let specialAntiCurseSpell: [String] = ["ghost", "spell", "witch", "remove", "decurse", "your", "me", "final", "monster", "branch", "wand", "touch", "kiss", "fly", "draw", "must", "band", "broom", "hard", "barrel", "cook", "hair", "ludogorec", "free", "boiko borisov", "spectre", "say", "told", "human", "weak", "pleasure", "says", "blood", "wound", "sword", "queen", "king", "fire", "hot", "30 years", "forever", "baby", "magic", "pain", "forest", "troll", "eye", "flesh", "brain", "dark", "dirty", "👻", "☠️", "💀", "🎃", "👽", "🧙‍♀️", "🧝‍♂️", "🧙‍♂️", "🕷", "🦂", "🦇", "🦉", "🐉", "🐲", "🌙", "🌪"]
    static let specialMessages: [String] = ["How many ghosts are around me", "Give me the anti-spell", "Hello Spectre", "Hi Spectre", "Who cursed me", "Who is haunting me", "What is the afterlife", "\u{0001F44B}"]
    static var specialAnswers: [String] {
        get {
            return [getGhostsNearby(),
                    antiCurse,
                    "Greetings " + (RealmManager.currentLoggedUser()?.state)!,
                    "Greetings " + (RealmManager.currentLoggedUser()?.state)!,
                    theLastOneWhoHaunted(),
                    theLastOneWhoHaunted(),
                    "All human beings have eternal life. No matter how strongly intellectuals may reject the idea, our souls are eternal; we are beings living in an eternal chain that consists of past, present and future.",
                    "\u{0001F44B}",
                    "I can't help you with that!"]
        }
    }
    static var word: String {
        return specialAntiCurseSpell.random
    }
    
    static var antiCurse: String {
        if RealmManager.currentLoggedUser()?.curse != "None" {
            if UserDefaults.standard.string(forKey: Constants.UserDefaults.antiCurse) == nil {
                let numberOfWords = Int.random(min: 5,
                                               max: 12)
                let composedSentence = compose({ word },
                                               count: numberOfWords,
                                               joinBy: .space,
                                               endWith: .dot,
                                               decorate: { $0.firstLetterCapitalized() })
                UserDefaults.standard.set(composedSentence, forKey: Constants.UserDefaults.antiCurse)
                let fireAt = Date(timeIntervalSinceNow: 30)
                let timer = Timer.init(fireAt: fireAt, interval: 0, target: self, selector: #selector(removeAntiCurse), userInfo: nil, repeats: false)
                RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
                return composedSentence + "\n\n\nYou have 30 seconds.\nSay the anti-spell to the one who cursed you."
            }
            return "You already have the anti-spell"
        }
        return "You are not cursed my friend"
        
    }
    
    //    MARK: Functions
    
    static func getGhostsNearby() -> String {
        let realm = try! Realm()
        return String(realm.objects(UserModel.self).filter("state = %@ AND userID != %d", "Ghost", UserDefaults.standard.integer(forKey: Constants.UserDefaults.loggedUserID)).count)
    }
    
    static func theLastOneWhoHaunted() -> String {
        if let userUniqueDeviceID = UserDefaults.standard.string(forKey: Constants.UserDefaults.curseUserUniqueDeviceID) {
            if let username = UserDefaults.standard.string(forKey: Constants.UserDefaults.curseUserUsername) {
                return "You are cursed by " + (RealmManager.userWith(uniqueID:  userUniqueDeviceID, andUsername: username)?.username)!
            }
        }
        return "I can't find the last ghost who haunted you!"
    }
    
    
    static func properAnswer(forMessage message: String) -> String {
        let userMessageWords = message.components(separatedBy: " ").map { word in word.lowercased() }
        let acc = specialMessages.map { sentence -> Int in
            let wordsSet = Set(sentence.components(separatedBy: " ").map { word in word.lowercased() } )
            return wordsSet.intersection(userMessageWords).count
        }
        print(acc)
        if let max = acc.max() {
            if max > 0 {
                if (specialMessages[acc.index(of: max)!].components(separatedBy: " ").count - 1) <= max {
                    return specialAnswers[acc.index(of: max)!]
                }
            }
        }
        return specialAnswers.last!
    }
    
    @objc static func removeAntiCurse() {
        UserDefaults.standard.set(nil, forKey: Constants.UserDefaults.antiCurse)
        UserDefaults.standard.synchronize()
    }
    
    
    fileprivate static func compose(_ provider: () -> String,
                                    count: Int,
                                    joinBy middleSeparator: Separator,
                                    endWith endSeparator: Separator = .none,
                                    decorate decorator: ((String) -> String)? = nil) -> String {
        var string = ""
        
        for index in 0..<count {
            string += provider()
            
            if (index < count - 1) {
                string += middleSeparator.rawValue
            } else {
                string += endSeparator.rawValue
            }
        }
        
        if let decorator = decorator {
            string = decorator(string)
        }
        
        return string
    }
    
}

//MARK: SpectreManager class

class SpectreManager {
    
    let nearbyUsersDelegate: NearbyUsersDelegate?
    let spectrePeerID = MCPeerID(displayName: "Spectre")
    
    init(nearbyUsersDelegate: NearbyUsersDelegate) {
        self.nearbyUsersDelegate = nearbyUsersDelegate
    }
    
    func startLoopingForSpectres() {
        print("startLoopingForSpectres")
        let timer = Timer.init(fireAt: Date(), interval: 10, target: self, selector: #selector(checkForSpectres), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
    }
    
    @objc func checkForSpectres() {
        let number = drand48()
        var chances = 0.25
        if let gift = UserDefaults.standard.value(forKey: Constants.UserDefaults.gift) {
            let gift = gift as! [String: Any]
            if gift["username"] as? String == RealmManager.currentLoggedUser()?.username {
                let date = gift["date"] as! Date
                if date.timeIntervalSinceNow > -3600*24 {
                    chances = 0.5
                }
            }
        }
        print(chances)
        if number <= chances {
            let realm = try! Realm()
            if let spectre = realm.objects(UserModel.self).filter("state = %@", "Spectre").first {
                self.nearbyUsersDelegate?.didFindNewUser(user: spectre, peerID: spectrePeerID)
            }
            
        }
        else {
            self.nearbyUsersDelegate?.didLostUser(peerID: spectrePeerID)
        }
    }
}



