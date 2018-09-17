//
//  MockUsersConnectivity.swift
//  LimboTests
//
//  Created by A-Team User on 11.09.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import RealmSwift
@testable import Limbo

class MockUsersConnectivity: UsersConnectivityDelegate {
    func sendMessage(messageModel: MessageModel, toPeerID: MCPeerID) -> Bool {
        print("sendMessage")
        return true
    }
    
    func sendJSONtoGame(dataDict: [String : String], toPeerID: MCPeerID) -> Bool {
        print("sendJSONtoGame")
        return true
    }
    
    func getPeerIDForUID(uniqueID: String) -> MCPeerID? {
        print("getPeerIDForUID")
        return nil
    }
    
    
}

class MockNearbyUsersDelegate: NearbyUsersDelegate {
    func didFindNewUser(user: UserModel, peerID: MCPeerID) {    }
    
    func didFindNewChatRoom(chatRoomThreadSafeReference: ThreadSafeReference<ChatRoomModel>) {    }
    
    func didLostUser(peerID: MCPeerID) {    }
    
    
}
