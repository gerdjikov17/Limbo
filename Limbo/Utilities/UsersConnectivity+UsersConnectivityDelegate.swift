//
//  UsersConnectivity+UsersConnectivityDelegate.swift
//  Limbo
//
//  Created by A-Team User on 31.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import Foundation
import UIKit
import MultipeerConnectivity
import RealmSwift

extension UsersConnectivity: UsersConnectivityDelegate {
    func sendMessage(messageModel: MessageModel, toPeerID: MCPeerID) -> Bool {
        if !self.session.connectedPeers.contains(toPeerID) {
            self.inviteUser(peerID: toPeerID)
        }
        if let toPeer = getPeerIDForUID(uniqueID: toPeerID.displayName) {
            do {
                let data = NSKeyedArchiver.archivedData(withRootObject: messageModel.toDictionary())
                try self.session.send(data, toPeers: [toPeer], with: .reliable)
                return true
            }
            catch let error {
                NSLog("%@", "Error for sending: \(error)")
                return false
            }
        }
        else {
            let pointForToast = CGPoint(x: (UIApplication.shared.keyWindow?.center.x)!, y: ((UIApplication.shared.keyWindow?.bounds.height)! - CGFloat(100)))
            UIApplication.shared.keyWindow?.makeToast("This user is offline and won't receive messages from you.", point:pointForToast , title: "", image: #imageLiteral(resourceName: "ghost_avatar.png"), completion: nil)
            return false
        }
    }
    
    func sendJSONtoGame(dataDict: [String: String], toPeerID: MCPeerID) -> Bool {
        if !self.gameSession.connectedPeers.contains(toPeerID) {
            self.inviteUser(peerID: toPeerID)
        }
        if let toPeer = getPeerIDForUID(uniqueID: toPeerID.displayName) {
            do {
                let data = try! JSONSerialization.data(withJSONObject: dataDict, options: .sortedKeys)
                try self.gameSession.send(data, toPeers: [toPeer], with: .reliable)
                return true
            }
            catch let error {
                NSLog("%@", "Error for sending: \(error)")
                return false
            }
        }
        else {
            let pointForToast = CGPoint(x: (UIApplication.shared.keyWindow?.center.x)!, y: ((UIApplication.shared.keyWindow?.bounds.height)! - CGFloat(100)))
            UIApplication.shared.keyWindow?.makeToast("This user is offline and won't receive messages from you.", point:pointForToast , title: "", image: #imageLiteral(resourceName: "ghost_avatar.png"), completion: nil)
            return false
        }
    }
    
    func setChatDelegate(newDelegate: ChatDelegate) {
        self.chatDelegate = newDelegate
    }
    
    func getPeerIDForUID(uniqueID: String) -> MCPeerID? {
        for peerID in self.foundPeers! {
            if peerID.displayName == uniqueID {
                return peerID
            }
        }
        return nil
    }
    
}
