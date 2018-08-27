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
    func didFindNewChatRoom(chatRoomThreadSafeReference: ThreadSafeReference<ChatRoomModel>)
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

protocol VoiceRecorderInteractorDelegate {
    func didFinishRecording()
}

protocol OptionsDelegate {
    func clearHistory()
    func showImages()
}

protocol GroupChatDelegate {
    func createGroupChat(withChatRooms chatRooms: [ChatRoomModel])
}

// MARK: Chat Module

protocol ChatPresenterInterface {
    func getMessages() -> [MessageModel]
    func requestMoreMessages()
    
    func didTapOnImage(image: UIImage, fromUser sender: String)
    func image(forMessage message: MessageModel, andIndexPath indexPath: IndexPath) -> UIImage?
    func properImage(imageName: String) -> UIImage
    
    func didTapOnOptionsButton(navigatoinButton: UIBarButtonItem)
    func didTapOnItemsButton(sourceView: UIView)
    func didTapOnAddPhotoButton()
    
    func voiceRecordButtonTap()
    
    func sendButtonTap(message: String)
    func silencedCallBack()
    func didFetchMessages()
    func requestMessages()
    func newMessage(message: MessageModel)
}

protocol ChatViewInterface {
    func reloadAllData()
    func reload(indexPaths: [IndexPath])
    func scrollTo(indexPath: IndexPath, at: UITableViewScrollPosition, animated: Bool)
    func setNavigationItemName(name: String)
    func showSilencedMessage()
}

protocol ChatInteractorInterface {
    func sendMessageToUser(message: String)
    func getMessageResults() -> Results<MessageModel>?
    func handleMessage(message: String)
    func finishedPickingImage(pickedImage: UIImage)
    func currentRoomName() -> String
    
    func clearHistory(completionHandler: ())
}

protocol ChatRouterInterface {
    func presentImage(image: UIImage, sender: String)
    func presentOptions(barButtonItem: UIBarButtonItem)
    func presentItems(forUser: UserModel, sourceView: UIView)
    func presentAlertController(alertController: UIAlertController)
    func presentAllImagesCVC(messagesHistory: Results<MessageModel>)
    func presentUIImagePicker()
    func presentVoiceRecorder(voiceRecordeDelegate: VoiceRecorderInteractorDelegate)
}
