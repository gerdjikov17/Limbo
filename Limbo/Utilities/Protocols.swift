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
import NVActivityIndicatorView

protocol NearbyUsersDelegate {
    func didFindNewUser(user: UserModel, peerID: MCPeerID)
    func didFindNewChatRoom(chatRoomThreadSafeReference: ThreadSafeReference<ChatRoomModel>)
    func didLostUser(peerID: MCPeerID)
}

protocol UsersConnectivityDelegate {
    func sendMessage(messageModel: MessageModel, toPeerID: MCPeerID) -> Bool
    func sendJSONtoGame(dataDict: [String: String], toPeerID: MCPeerID) -> Bool
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
    func changeAvatarTap()
    func usersInCurrentRoom() -> [UserModel]
    func pushVC(vc: UIViewController)
}

protocol GroupChatDelegate {
    func createGroupChat(withUsers users: [UserModel])
}

// MARK: Chat Module

protocol SetableForMessageModel {
    func set(forMessageModel message: MessageModel, senderImage: UIImage?)
}

protocol ChatInteractorToPresenterInterface: class {
    func silencedCallBack()
    func newMessage(message: MessageModel)
}

protocol ChatViewToPresenterInterface {
//    func getMessages() -> [MessageModel]
    func requestMessages()
    func requestMoreMessages()
    
    func viewDidDisappear()
    func viewDidLoad()
    func viewDidAppear()
    
    func makeTableViewScrollToLastRow(animated: Bool)
    
    func sendButtonTap(message: String)
    func didTapOnImage(recognizer: UITapGestureRecognizer, inTableView tableView: UITableView)
    func didTapOnMessage(recognizer: UITapGestureRecognizer, inTableView tableView: UITableView)
    func didTapOnOptionsButton(navigatoinButton: UIBarButtonItem)
    func didTapOnItemsButton(sourceView: UIView)
    func didTapOnAddPhotoButton(sourceView: UIView)
    func voiceRecordButtonTap()
}

@objc protocol ChatViewInterface {
    func reloadAllData()
    func insert(indexPaths: [IndexPath])
    func scrollTo(indexPath: IndexPath, at: UITableViewScrollPosition, animated: Bool)
    func setNavigationItemName(name: String)
    func showSilencedMessage()
    func didTapOnImage(recognizer: UITapGestureRecognizer)
    func didTapOnMessage(recognizer: UITapGestureRecognizer)
}
protocol ChatInteractorInterface: class {
    func getMessageResults() -> Results<MessageModel>?
    func handleMessage(message: String)
    func finishedPickingImage(pickedImage: UIImage)
    func currentRoomName() -> String
    func currentRoom() -> ChatRoomModel
    func invalidateToken()
    func didStartPresentingSomeVC()
    
    func clearHistory(completionHandler: ())
    func changeRoomName(newName: String)
}

protocol ChatRouterInterface {
    func presentImage(photoMessages: Results<MessageModel>, index: Int)
    func presentOptions(barButtonItem: UIBarButtonItem, optionsType: OptionsType, optionsDelegate: OptionsDelegate)
    func presentItems(forUser: UserModel, sourceView: UIView)
    func presentAlertController(alertController: UIAlertController)
    func presentAllImagesCVC(messagesHistory: Results<MessageModel>, completion: (() -> Void)?)
    func presentUIImagePicker(sourceType: UIImagePickerControllerSourceType,
                              imgPickerDelegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate),
                              completion: (() -> Void)?) 
    func presentVoiceRecorder(voiceRecordeDelegate: VoiceRecorderInteractorDelegate, completion: (() -> Void)?)
    func presentGalleryVC(imgPickerDelegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate),
                          sourceView: UIView,
                          completion: (() -> Void)?)
    func presentAvatars(chatRoom: ChatRoomModel)
    func pushVC(vc: UIViewController)
}

// MARK: NearbyUsers Module

protocol NearbyUsersViewToPresenterInterface {
    func firstInitialization()
    func viewDidAppear()
    func viewDidDisappear()
    func medallionImageTap(sourceView: UIView, presentingVC: UIViewController)
    func candleImageTap(sourceView: UIView, presentingVC: UIViewController)
    func batteryLevelDidChange(batteryLevel: Float)
    func userImageTap()
    func signOutButtonTap()
    func numberOfItems() -> Int
    func chatRoomModelView(forIndexPath indexPath: IndexPath) -> ChatRoomModelView
    func didSelectItem(atIndexPath indexPath: IndexPath)
}
protocol NearbyUsersInteractorToPresenterInterface {
    func userObjectChanged(user: UserModel)
    func finishedSync(viewModels: [ChatRoomModelView])
    func newChatRoom(chatRoomModelView: ChatRoomModelView)
    func foundSpectre()
    func lostSpectre()
}

protocol NearbyUsersPresenterToViewInterface {
    func setUIContent(userModel: UserModel)
    func reloadData()
    func showToast(message: String)
    func showGiftToast()
    func userImageView() -> UIImageView
}

protocol NearbyUsersPresenterToInteractorInterface {
    func initProperties()
    func startLoopingForSpectres()
    func checkForCurses()
    func setBatteryLevelForCurrentUser(batteryLevel: Float)
    func hasGifts() -> Bool
    func userDidSignOut()
    func isCurrentUserBlind() -> Bool
    func chatRoom(forIndexPath indexPath: IndexPath) -> ChatRoomModel
    func didSelectRoom(withUUID uuid: String?)
    func usersConnectivityDelegate() -> UsersConnectivityDelegate
    func replyAction(withText text: String, andUserInfo userInfo: [AnyHashable: Any]) -> (success: Bool, toastMessage: String?)
    func inviteUsersIn(chatRoom: ChatRoomModel)
    func filterUsersToShow()
    func currentVisibleUsers() -> [UserModel]?
    func addGroupChatCell()
    func showGroupChats()
}

protocol NearbyUsersPresenterToRouterInterface {
    func presentItemPopover(specialItem: SpecialItem, sourceView: UIView, presentingVC: UIViewController)
    func presentLoginVC(loginDelegate: LoginDelegate)
    func presentUserAvatars(user: UserModel, imagePickingDelegate: ImagePickingToPresenterInterface)
    func createAndPushChatModule(chatRoom: ChatRoomModel, usersConnectivityDelegate: UsersConnectivityDelegate)
    func createAndPushAllUsersTVC(users: [UserModel], groupChatDelegate: GroupChatDelegate)
    func addActivityIndicator(toImageView imageView: UIImageView)
    func removeActivityIndicator(fromImageView imageView: UIImageView)
}

protocol ImagePickingToPresenterInterface {
    func didStarUploadingImage()
    func didFinishUploadingImage()
}
