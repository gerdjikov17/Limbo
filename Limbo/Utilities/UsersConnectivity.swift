//
//  DeviceConnectivity.swift
//  MCConnectionTest
//
//  Created by A-Team User on 20.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class UsersConnectivity: NSObject {
    
    private var userModel: UserModel
    private var myPeerID: MCPeerID
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    private let serviceBrowser: MCNearbyServiceBrowser
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()
    
    var delegate: NearbyUsersDelegate?
    var chatDelegates: [ChatDelegate]?
    
    
    init(userModel: UserModel) {
        self.userModel = userModel
        self.userModel.setState(batteryLevel: UIDevice.current.batteryLevel)
        self.myPeerID = MCPeerID(displayName: userModel.username)
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: self.myPeerID, discoveryInfo: ["state": self.userModel.state], serviceType:Constants.MCServiceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: self.myPeerID, serviceType: Constants.MCServiceType)
        self.chatDelegates = Array()
        
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
    
    
    func send(textString : String) {
        NSLog("%@", "sendColor: \(textString) to \(session.connectedPeers.count) peers")
        
        if session.connectedPeers.count > 0 {
            do {
                try self.session.send(textString.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
            }
            catch let error {
                NSLog("%@", "Error for sending: \(error)")
            }
        }
        
    }
    
}

extension UsersConnectivity: UsersConnectivityDelegate {
    func sendMessage(messageModel: MessageModel, toPeerID: MCPeerID) {
        if !session.connectedPeers.contains(toPeerID) {
            self.serviceBrowser.invitePeer(toPeerID, to: session, withContext: nil, timeout: 10)
        }
        do {
            let data = NSKeyedArchiver.archivedData(withRootObject: messageModel.toDictionary())
            try self.session.send(data, toPeers: [toPeerID], with: .reliable)
        }
        catch let error {
            NSLog("%@", "Error for sending: \(error)")
        }
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
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        if let userState = info!["state"] {
            let userModel: UserModel! = UserModel(username: peerID.displayName, state: userState)
            self.delegate?.didFindNewUser(user: userModel, peerID: peerID)
        }
        
        
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
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
        for chatDelegate in self.chatDelegates! {
            chatDelegate.didReceiveMessage(messageModel: messageModel, fromPeerID: peerID)
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
