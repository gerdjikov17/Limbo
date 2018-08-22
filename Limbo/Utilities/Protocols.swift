//
//  Protocols.swift
//  Limbo
//
//  Created by A-Team User on 24.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import RealmSwift

protocol NearbyUsersDelegate {
    func didFindNewUser(user: UserModel, peerID: MCPeerID)
    func didLostUser(peerID: MCPeerID)
}

protocol UsersConnectivityDelegate {
    func sendMessage(messageModel: MessageModel, toPeerID: MCPeerID) -> Bool
    func sendJSONtoGame(dataDict: [String: String], toPeerID: MCPeerID) -> Bool
    func setChatDelegate(newDelegate: ChatDelegate)
    func getPeerIDForUID(uniqueID: String) -> MCPeerID?
}

protocol LoginDelegate {
    func didLogin(userModel: UserModel)
}

protocol ChatDelegate: AnyObject {
    func didReceiveMessage(threadSafeMessageRef: ThreadSafeReference<MessageModel>, fromPeerID: MCPeerID)
    func didReceiveCurse(curse: Curse, remainingTime: Double)
}

protocol VoiceRecorderUIDelegate {
    func isReadyToRecord()
    func didFinishRecording()
}

protocol OptionsDelegate {
    func clearHistory()
    func showImages()
}
