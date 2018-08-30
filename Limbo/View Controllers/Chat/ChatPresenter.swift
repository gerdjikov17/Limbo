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
    
}

extension ChatPresenter: ChatInteractorToPresenterInterface {
    
    func newMessage(message: MessageModel) {
        print(self.messages.count)
        self.messages.append(message)
        print(self.messages.count)
        let newIndexPath = IndexPath(row: self.messages.count - 1 , section: 0)
        self.chatView.reloadAllData()
        self.chatView.scrollTo(indexPath: newIndexPath, at: .bottom, animated: true)
    }
    
    func silencedCallBack() {
        self.chatView.showSilencedMessage()
    }
    
    func didFetchMessages() {
        self.chatView.reloadAllData()
    }
}

extension ChatPresenter: ChatViewToPresenterInterface {
    func sendButtonTap(message: String) {
        self.chatInteractor!.handleMessage(message: message)
    }
    
    func viewDidDisappear() {
        self.chatInteractor?.invalidateToken()
    }
    
    func requestMessages() {
        self.messages = Array(self.chatInteractor!.getMessageResults()![startIndex...])
        self.chatView.setNavigationItemName(name: self.chatInteractor!.currentRoomName())
    }
    
    func lastMessageIndex() -> Int {
        return self.messages.count - 1
    }
    
    func requestMoreMessages() {
        let countBeforeUpdate = self.messages.count
        guard countBeforeUpdate > 0 else {
            return
        }
        
        rangeOfMessagesToShow += 50
        self.messages = Array(self.chatInteractor!.getMessageResults()![self.startIndex...])
        
        let countAfterUpdate = self.messages.count
        
        self.chatView.reloadAllData()
        self.chatView.scrollTo(indexPath: IndexPath(row: countAfterUpdate - countBeforeUpdate, section: 0), at: .top, animated: false)
    }
    
    func image(forMessage message: MessageModel, andIndexPath indexPath: IndexPath) -> UIImage? {
        if message.sender != RealmManager.currentLoggedUser() {
            if indexPath.row - 1 >= 0 {
                if self.messages[indexPath.row - 1].sender != message.sender {
                    if let avatarString = message.sender?.avatarString {
                        return properImage(imageName: avatarString)
                    }
                }
                else {
                    return nil
                }
            }
            else {
                if let avatarString = message.sender?.avatarString {
                    return properImage(imageName: avatarString)
                }
            }
        }
        return nil
    }
    
    func properImage(imageName: String) -> UIImage {
        if let defaultImage = UIImage(named: imageName) {
            return defaultImage
        }
        else {
            if let imgurImage = try! UIImage(data: Data(contentsOf: URL(string: imageName)!)) {
                return imgurImage
            }
            return #imageLiteral(resourceName: "ghost_avatar.png")
        }
    }
    
    func didTapOnImage(recognizer: UITapGestureRecognizer, inTableView tableView: UITableView) {
        let touchPoint = recognizer.location(in: tableView)
        let indexPath: IndexPath = tableView.indexPathForRow(at: touchPoint)!
        guard let cell = tableView.cellForRow(at: indexPath) as? PhotoTableViewCell else {
            return
        }
        guard let image = cell.sentPhotoImageView.image else {
            return
        }
        let message = self.messages[indexPath.row]
        guard let sender = message.sender else {
            return
        }
        
        self.chatRouter?.presentImage(image: image, sender: sender.username)
    }
    
    func didTapOnMessage(recognizer: UITapGestureRecognizer, inTableView tableView: UITableView) {
        let touchPoint = recognizer.location(in: tableView)
        let indexPath: IndexPath = tableView.indexPathForRow(at: touchPoint)!
        
        tableView.beginUpdates()
        
        if self.selectedIndexPathForTimeStamp == indexPath {
            self.selectedIndexPathForTimeStamp = nil
        }
        else {
            self.selectedIndexPathForTimeStamp = indexPath
        }
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
        self.chatRouter?.presentUIImagePicker(imgPickerDelegate: self)
    }
    
    func voiceRecordButtonTap() {
        self.chatRouter?.presentVoiceRecorder(voiceRecordeDelegate: self.chatInteractor as! VoiceRecorderInteractorDelegate)
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
        self.chatRouter!.presentAllImagesCVC(messagesHistory: self.chatInteractor!.getMessageResults()!)
    }
    
    func changeGroupChatName(newName: String) {
        self.chatInteractor?.changeRoomName(newName: newName)
        self.chatView.setNavigationItemName(name: newName)
    }
    
    func usersInCurrentRoom() -> [UserModel] {
        return Array(self.chatInteractor!.currentRoom().usersChattingWith)
    }
    
    func pushVC(vc: UIViewController) {
        self.chatRouter?.pushVC(vc: vc)
    }
}
