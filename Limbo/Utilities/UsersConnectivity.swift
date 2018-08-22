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
    
    //    MARK: Properties
    
    private var userModel: UserModel?
    var notificationToken: NotificationToken?
    var myPeerID: MCPeerID
    private var serviceAdvertiser: MCNearbyServiceAdvertiser
    private let serviceBrowser: MCNearbyServiceBrowser
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerID, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        return session
    }()
    
    var delegate: NearbyUsersDelegate?
    var chatDelegate: ChatDelegate?
    
    //    MARK: Initialization
    
    init(userModel: UserModel, delegate: NearbyUsersDelegate, peerID: MCPeerID?) {
        self.userModel = RealmManager.currentLoggedUser()!
        self.delegate = delegate
        if let unwrappedPeerID = peerID {
            self.myPeerID = unwrappedPeerID
        }
        else {
            self.myPeerID = MCPeerID(displayName: (UIDevice.current.identifierForVendor?.uuidString)!.appending(".chat"))
        }
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: self.myPeerID, discoveryInfo: ["username": self.userModel!.username, "state": self.userModel!.state, "avatar": self.userModel!.avatarString] as Dictionary, serviceType:Constants.MCServiceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: self.myPeerID, serviceType: Constants.MCServiceType)
        
        super.init()
        
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
        
        self.notificationToken = userModel.observe({ change in
            
            switch change {
            case .change(let properties) :
                for property in properties {
                    var discoveryInfo: Dictionary<String, String>
                    if property.name == "avatarString" {
                        discoveryInfo = ["username": userModel.username, "state": userModel.state, "avatar": property.newValue as! String]
                    }
                    else if property.name == "state" {
                        discoveryInfo = ["username": userModel.username, "state": property.newValue as! String, "avatar": userModel.avatarString]
                    }
                    else {
                        discoveryInfo = ["username": userModel.username, "state": userModel.state, "avatar": userModel.avatarString]
                    }
                    print("setting new advertiser with discovery info = %@", discoveryInfo)
                    DispatchQueue.global(qos: .background).async {
                        self.serviceAdvertiser.stopAdvertisingPeer()
                        self.serviceBrowser.stopBrowsingForPeers()
                        //                    sleep(2)
                        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: self.myPeerID, discoveryInfo: discoveryInfo, serviceType:Constants.MCServiceType)
                        self.serviceAdvertiser.delegate = self
                        self.serviceAdvertiser.startAdvertisingPeer()
                        sleep(2)
                        self.serviceAdvertiser.stopAdvertisingPeer()
                        sleep(2)
                        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: self.myPeerID, discoveryInfo: discoveryInfo, serviceType:Constants.MCServiceType)
                        self.serviceAdvertiser.delegate = self
                        self.serviceAdvertiser.startAdvertisingPeer()
                        self.serviceBrowser.startBrowsingForPeers()
                    }
                }
            default:
                break
            }
            
        })
    }
    
    deinit {
        self.notificationToken?.invalidate()
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
        
    }
    
    func didSignOut() {
//        self.session = nil
//        self.serviceAdvertiser.delegate = nil
        self.notificationToken?.invalidate()
        self.session.disconnect()
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
}

// MARK: Protocol conforms

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
        
        if peerID.displayName.hasSuffix(".game") {
            self.foundGamePeer(peerID: peerID, withDiscoveryInfo: info)
        }
        else if peerID.displayName.hasSuffix(".chat") {
            self.foundChatPeer(peerID: peerID, withDiscoveryInfo: info)
            self.inviteUser(peerID: peerID)
        }
    }
    
    func shouldShowUserDependingOnState(currentUserState: String, foundUserState: String) -> Bool {
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
        
        let realm = try! Realm()
        if let user = realm.objects(UserModel.self).filter("uniqueDeviceID == %@ AND state != %@", peerID.displayName, "Offline").filter("state != %@", "Spectre").first {
            realm.beginWrite()
            user.state = "Offline"
            try! realm.commitWrite()
        }
        realm.refresh()
        self.delegate?.didLostUser(peerID: peerID)
    }
    
}

extension UsersConnectivity : MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state.rawValue)")
        
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data)")
        if peerID.displayName.hasSuffix(".game") {
            self.handleGameData(data: data, fromPeer: peerID)
        }
        else {
            self.handleChatData(data: data, fromPeer: peerID)
        }
    }
    
    func isPeerAGhost(peerID: MCPeerID, withUsername username: String) -> Bool {
        if let user = RealmManager.userWith(uniqueID: peerID.displayName, andUsername: username) {
            return user.state == "Ghost"
        }
        else {
          return false
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
}
