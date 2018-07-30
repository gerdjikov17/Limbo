//
//  DeviceConnectivity.swift
//  MCConnectionTest
//
//  Created by A-Team User on 20.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import RealmSwift

class UsersConnectivity: NSObject {
    
    private var userModel: UserModel
    private var myPeerID: MCPeerID
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    private let serviceBrowser: MCNearbyServiceBrowser
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerID, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        return session
    }()
    
    var delegate: NearbyUsersDelegate?
    var chatDelegate: ChatDelegate?
    
    
    init(userModel: UserModel) {
        self.userModel = userModel
        self.myPeerID = MCPeerID(displayName: (UIDevice.current.identifierForVendor?.uuidString)!)
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: self.myPeerID, discoveryInfo: ["username": userModel.username, "state": self.userModel.state, "avatar": self.userModel.avatarString], serviceType:Constants.MCServiceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: self.myPeerID, serviceType: Constants.MCServiceType)
        
        super.init()
        
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    func didSignOut() {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
}

extension UsersConnectivity: UsersConnectivityDelegate {
    func sendMessage(messageModel: MessageModel, toPeerID: MCPeerID) -> Bool {
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
    
    func setChatDelegate(newDelegate: ChatDelegate) {
        self.chatDelegate = newDelegate
    }
    
    func getPeerIDForUID(uniqueID: String) -> MCPeerID? {
        for peerID in self.session.connectedPeers {
            if peerID.displayName == uniqueID {
                return peerID
            }
        }
        return nil
    }
    
}

extension UsersConnectivity: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.session)
    }
    
}

extension UsersConnectivity : MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func inviteUser(peerID: MCPeerID) {
        self.serviceBrowser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        if let userState = info!["state"] {
            let userModel: UserModel! = UserModel(username: info!["username"]!, state: userState)
            userModel.avatarString = info!["avatar"]!
//            if shouldShowUserDependingOnState(foundUserState: userState) {
                self.delegate?.didFindNewUser(user: userModel, peerID: peerID)
//            }
            
            browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
        }
    }
    
    func shouldShowUserDependingOnState(foundUserState: String) -> Bool {
        let currentUserState = self.userModel.state
        switch currentUserState {
        case "Human":
            if (foundUserState == "Human") { return true }
            else { return false }
        case "Dying":
            if foundUserState == "Dying"{ return true }
            else { return false }
        case "Hollow":
            if (foundUserState == "Hollow") || (foundUserState == "Dying") { return true }
            else { return false }
        case "Undead":
            if (foundUserState == "Hollow") || (foundUserState == "Dying") || (foundUserState == "Undead") || (foundUserState == "Ghost") { return true }
            else { return false }
        default:
            return true
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
        self.delegate?.didLostUser(peerID: peerID)
    }
    
}

extension UsersConnectivity : MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state)")

    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data)")
        let dataDict = NSKeyedUnarchiver.unarchiveObject(with: data) as! Dictionary<String, Any>
        let messageModel = MessageModel(withDictionary: dataDict)
        let realm = try! Realm()
        realm.beginWrite()
        realm.add(messageModel)
        try? realm.commitWrite()
        let threadSafeMessage = ThreadSafeReference(to: messageModel)
        if let fromPeer = self.getPeerIDForUID(uniqueID: peerID.displayName) {
            chatDelegate!.didReceiveMessage(threadSafeMessageRef: threadSafeMessage, fromPeerID: fromPeer)
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
    
}
