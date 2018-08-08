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
    static var specialAnswers: [String] {
        get {
            return [getGhostsNearby(), "Later", "I can't help you with that!"]
        }
    }
    
    static func getGhostsNearby() -> String {
        let realm = try! Realm()
        return String(realm.objects(UserModel.self).filter("state = %@ AND userID != %d", "Ghost", UserDefaults.standard.integer(forKey: Constants.UserDefaults.loggedUserID)).count)
    }
    
    static func properAnswer(forMessage message: String) -> String {
        let userMessageWords = message.components(separatedBy: " ").map { word in word.lowercased() }
        let acc = Spectre.specialMessages.map { sentence -> Int in
            let wordsSet = Set(sentence.components(separatedBy: " ").map { word in word.lowercased() } )
            return wordsSet.intersection(userMessageWords).count
        }
        
        print(acc)
        if let max = acc.max() {
            if max > 3 {
                return specialAnswers[acc.index(of: max)!]
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
