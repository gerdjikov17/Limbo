//
//  Spectre.swift
//  Limbo
//
//  Created by A-Team User on 1.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit
import RealmSwift
import MultipeerConnectivity

class Spectre {
    
    static let specialMessages: [String] = ["How many ghosts are around me?", "Give me the anti-spell!"]
    static let specialAnswers: [String] = [getGhostsNearby(), "Later", "I can't help you with that!"]
    
    static func getGhostsNearby() -> String {
        let realm = try! Realm()
        return String(realm.objects(UserModel.self).filter("state = %@ AND userID != %d", "Ghost", UserDefaults.standard.integer(forKey: Constants.UserDefaults.loggedUserID)).count)
    }
    
    static func properAnswer(forMessage message: String) -> String {
        if message.replacingOccurrences(of: " ", with: "").count > 10 {
            var dictWithCommonWords: [String: Int] = NSDictionary.init(objects: Array.init(repeating: 0, count: Spectre.specialMessages.count) as [Int], forKeys: Spectre.specialMessages as [NSCopying]) as! [String : Int]
            
            for component in message.components(separatedBy: " ") {
                for message in Spectre.specialMessages {
                    if message.lowercased().range(of: component.lowercased()) != nil {
                        dictWithCommonWords.updateValue(dictWithCommonWords[message]! + 1 , forKey: message)
                    }
                }
            }
            
            for key in dictWithCommonWords.keys {
                if dictWithCommonWords[key]! > 3 {
                    if let index = Spectre.specialMessages.index(of: key) {
                        switch index {
                        case 0: return Spectre.getGhostsNearby()
                        case 1: return Spectre.specialAnswers[1]
                        default: return Spectre.specialAnswers[2]
                        }
                    }
                }
            }
        }
        return Spectre.specialAnswers[2]
    }
    
}

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
        if number <= 0.5 {
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
