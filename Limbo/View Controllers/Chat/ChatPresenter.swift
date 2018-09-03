//
//  ChatPresenter.swift
//  Limbo
//
//  Created by A-Team User on 24.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit

class ChatPresenter: NSObject {
    var chatRouter: ChatRouterInterface?
    var chatInteractor: ChatInteractorInterface?
    weak var chatView: ChatViewInterface!
    
    var messages: [MessageModel]!
    var messagesHeights: [CGFloat]!
    
    var selectedIndexPathForTimeStamp: IndexPath?
    var rangeOfMessagesToShow = 50
    var startIndex: Int! {
        get {
            var returnIndex = self.chatInteractor!.getMessageResults()!.count - self.rangeOfMessagesToShow
            if returnIndex < 0 {
                returnIndex = 0
            }
            return returnIndex
        }
    }
    
    
    init(chatView: ChatViewInterface) {
        self.chatView = chatView
        super.init()
    }
    
    func heightForMessage(for message: MessageModel) -> CGFloat {
        if message.messageType == MessageType.Message.rawValue {
            return MessageCellsManager.calculateHeight(forMessage: message) + 6
        }
        else if message.messageType == MessageType.Voice_Record.rawValue {
            return 40
        }
        else {
            return 155
        }
    }
    
    func storeHeightForMessages(messages: [MessageModel]) {
        self.messagesHeights = Array()
        for message in messages {
            self.messagesHeights.append(self.heightForMessage(for: message))
        }
    }
    
}

extension ChatPresenter: ChatInteractorToPresenterInterface {
    
    func newMessage(message: MessageModel) {
        self.messages.append(message)
        self.messagesHeights.append(heightForMessage(for: message))
        print("appending message")
        let newIndexPath = IndexPath(row: self.messages.count - 1 , section: 0)
        self.chatView.insert(indexPaths: [newIndexPath])
        print("inserting row")
        self.chatView.scrollTo(indexPath: newIndexPath, at: .bottom, animated: true)
    }
    
    func silencedCallBack() {
        self.chatView.showSilencedMessage()
    }
}

extension ChatPresenter: ChatViewToPresenterInterface {
    func viewDidLoad() {
        self.makeTableViewScrollToLastRow(animated: false)
    }
    
    func viewDidAppear() {
        self.makeTableViewScrollToLastRow(animated: false)
    }
    
    func viewDidDisappear() {
        self.chatInteractor?.invalidateToken()
    }
    
    func makeTableViewScrollToLastRow(animated: Bool) {
        let indexPath = IndexPath(row: self.lastMessageIndex(), section: 0)
        if indexPath.row >= 0 {
            self.chatView.scrollTo(indexPath: indexPath, at: .bottom, animated: animated)
        }
    }
    
    func requestMessages() {
        self.messages = Array(self.chatInteractor!.getMessageResults()![startIndex...])
        
        self.storeHeightForMessages(messages: self.messages)
        
        self.chatView.setNavigationItemName(name: self.chatInteractor!.currentRoomName())
    }
    
    func lastMessageIndex() -> Int {
        return self.messages.count - 1
    }
    
    func requestMoreMessages() {
        let countBeforeUpdate = self.messages.count
        guard countBeforeUpdate > 0 else { return }
        
        rangeOfMessagesToShow += 50
        self.messages = Array(self.chatInteractor!.getMessageResults()![self.startIndex...])
        
        self.storeHeightForMessages(messages: self.messages)
        
        let countAfterUpdate = self.messages.count
        
        self.chatView.reloadAllData()
        self.chatView.scrollTo(indexPath: IndexPath(row: countAfterUpdate - countBeforeUpdate, section: 0), at: .top, animated: false)
    }
    
    func image(forMessage message: MessageModel, andIndexPath indexPath: IndexPath) -> UIImage? {
        guard message.sender != RealmManager.currentLoggedUser() else { return nil }
        guard indexPath.row - 1 >= 0 else {
            return properImage(imageName: message.sender!.avatarString)
        }
        guard self.messages[indexPath.row - 1].sender != message.sender else { return nil }
        
        return properImage(imageName: message.sender!.avatarString)
    }
    
    func properImage(imageName: String) -> UIImage {
        if let defaultImage = UIImage(named: imageName) {
            return defaultImage
        }
        else if let imgurImage = try! UIImage(data: Data(contentsOf: URL(string: imageName)!)){
//            image loading not yet optimized
            return imgurImage
        }
        return #imageLiteral(resourceName: "ghost_avatar.png")
    }
    
    func sendButtonTap(message: String) {
        self.chatInteractor!.handleMessage(message: message)
    }
    
    func didTapOnImage(recognizer: UITapGestureRecognizer, inTableView tableView: UITableView) {
        let touchPoint = recognizer.location(in: tableView)
        let indexPath: IndexPath = tableView.indexPathForRow(at: touchPoint)!
        
        guard let cell = tableView.cellForRow(at: indexPath) as? PhotoTableViewCell else { return }
        guard let image = cell.sentPhotoImageView.image else { return }
        
        let message = self.messages[indexPath.row]
        
        guard let sender = message.sender else { return }
        
        self.chatRouter?.presentImage(image: image, sender: sender.username)
    }
    
    func didTapOnMessage(recognizer: UITapGestureRecognizer, inTableView tableView: UITableView) {
        let touchPoint = recognizer.location(in: tableView)
        let indexPath: IndexPath = tableView.indexPathForRow(at: touchPoint)!
        
        tableView.beginUpdates()
        
        self.selectedIndexPathForTimeStamp = self.selectedIndexPathForTimeStamp == indexPath ? nil : indexPath
        
        tableView.endUpdates()
        
        if indexPath.row == self.messages.count - 1 {
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    func didTapOnOptionsButton(navigatoinButton: UIBarButtonItem) {
        let optionsType = self.chatInteractor!.currentRoom().usersChattingWith.count > 1 ? OptionsType.GroupChat : OptionsType.NormalChat
        self.chatRouter?.presentOptions(barButtonItem: navigatoinButton, optionsType: optionsType, optionsDelegate: self)
    }
    
    func didTapOnItemsButton(sourceView: UIView) {
        self.chatRouter?.presentItems(forUser: RealmManager.currentLoggedUser()!, sourceView: sourceView)
    }
    
    func didTapOnAddPhotoButton() {
        self.chatRouter?.presentUIImagePicker(imgPickerDelegate: self, completion: {
            self.chatInteractor?.didStartPresentingSomeVC()
        })
        
    }
    
    func voiceRecordButtonTap() {
        self.chatRouter?.presentVoiceRecorder(voiceRecordeDelegate: self.chatInteractor as! VoiceRecorderInteractorDelegate, completion: {
        self.chatInteractor?.didStartPresentingSomeVC()
            
        })
    }
}


extension ChatPresenter: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.chatInteractor!.finishedPickingImage(pickedImage: pickedImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ChatPresenter: OptionsDelegate {
    func clearHistory() {
        let alertController = UIAlertController(title: "Clear history",
                                                message: "In a result of clearing your history you wont be able to " +
            "recover it back.\nAre you sure you want to delete it ?", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
            self.chatInteractor?.clearHistory(completionHandler : {
                self.messages = Array()
                self.chatView.reloadAllData()
            }())
        }))
        alertController.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
            
        }))
        self.chatRouter!.presentAlertController(alertController: alertController)
    }
    
    func showImages() {
        self.chatRouter!.presentAllImagesCVC(messagesHistory: self.chatInteractor!.getMessageResults()!, completion: {
            self.chatInteractor?.didStartPresentingSomeVC()
        })
    }
    
    func changeGroupChatName(newName: String) {
        self.chatInteractor?.changeRoomName(newName: newName)
        self.chatView.setNavigationItemName(name: newName)
    }
    
    func changeAvatarTap() {
        self.chatRouter?.presentAvatars(chatRoom: self.chatInteractor!.currentRoom())
    }
    
    func usersInCurrentRoom() -> [UserModel] {
        return Array(self.chatInteractor!.currentRoom().usersChattingWith)
    }
    
    func pushVC(vc: UIViewController) {
        self.chatRouter?.pushVC(vc: vc)
    }
}
