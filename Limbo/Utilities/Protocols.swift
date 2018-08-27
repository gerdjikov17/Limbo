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
    func changeGroupChatName(newName: String)
    func usersInCurrentRoom() -> [UserModel]
    func pushVC(vc: UIViewController)
}

protocol GroupChatDelegate {
    func createGroupChat(withUsers users: [UserModel])
}

// MARK: Chat Module

protocol ChatInteractorToPresenterInterface {
    func silencedCallBack()
    func didFetchMessages()
    func newMessage(message: MessageModel)
}

protocol ChatViewToPresenterInterface {
    func getMessages() -> [MessageModel]
    func requestMessages()
    func requestMoreMessages()
    
    func image(forMessage message: MessageModel, andIndexPath indexPath: IndexPath) -> UIImage?
    func properImage(imageName: String) -> UIImage
    
    func sendButtonTap(message: String)
    func didTapOnImage(image: UIImage, fromUser sender: String)
    func didTapOnOptionsButton(navigatoinButton: UIBarButtonItem)
    func didTapOnItemsButton(sourceView: UIView)
    func didTapOnAddPhotoButton()
    func voiceRecordButtonTap()
}

protocol ChatRouterToPresenterInterface: ChatInteractorToPresenterInterface, ChatViewToPresenterInterface {
    
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
    func currentRoom() -> ChatRoomModel
    
    func clearHistory(completionHandler: ())
    func changeRoomName(newName: String)
}

protocol ChatRouterInterface {
    func presentImage(image: UIImage, sender: String)
    func presentOptions(barButtonItem: UIBarButtonItem, optionsType: OptionsType)
    func presentItems(forUser: UserModel, sourceView: UIView)
    func presentAlertController(alertController: UIAlertController)
    func presentAllImagesCVC(messagesHistory: Results<MessageModel>)
    func presentUIImagePicker()
    func presentVoiceRecorder(voiceRecordeDelegate: VoiceRecorderInteractorDelegate)
    func pushVC(vc: UIViewController)
}
