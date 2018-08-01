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
        print("checkForSpectres")
        let number = drand48()
        print(number)
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
