//
//  ChatRouter.swift
//  Limbo
//
//  Created by A-Team User on 24.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit
import RealmSwift

class ChatRouter: NSObject, ChatRouterInterface {
    
    var navigationController: UINavigationController!
    var storyboard: UIStoryboard!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.storyboard = UIStoryboard(name: "Main", bundle: nil)
        super.init()
    }
    
    static func createChatModule(using navigationController: UINavigationController,
                                 usersConnectivityDelegate: UsersConnectivityDelegate,
                                 chatRoom: ChatRoomModel) -> ChatViewController {
        
        let view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chatVC") as! ChatViewController
        
        let presenter = ChatPresenter(chatView: view)
        
        let interactor = ChatInteractor(chatDelegate: usersConnectivityDelegate,
                                        chatPresenter: presenter as ChatInteractorToPresenterInterface,
                                        chatRoom: chatRoom)
        
        let router = ChatRouter(navigationController: navigationController)
        view.chatPresenter = presenter as ChatViewToPresenterInterface
        presenter.chatRouter = router
        presenter.chatInteractor = interactor
        
        return view
    }
    
    func presentImage(image: UIImage, sender: String) {
        let chatImageVC = storyboard.instantiateViewController(withIdentifier: "chatImageVC") as! ChatImageViewController
        chatImageVC.image = image
        chatImageVC.senderUsername = sender
        self.navigationController.present(chatImageVC, animated: true, completion: nil)
    }
    
    func presentItems(forUser: UserModel, sourceView: UIView) {
        
        let itemsVC = storyboard.instantiateViewController(withIdentifier: "itemsVC") as! ItemsViewController
        itemsVC.user = forUser
        itemsVC.modalPresentationStyle = .popover
        itemsVC.preferredContentSize = CGSize(width: 120, height: 70)
        let popoverPresentationController = itemsVC.popoverPresentationController
        popoverPresentationController?.permittedArrowDirections = .down
        popoverPresentationController!.sourceView = sourceView
        popoverPresentationController!.sourceRect = sourceView.bounds
        popoverPresentationController!.delegate = self
        self.navigationController.present(itemsVC, animated: true, completion: nil)
    }
    
    func presentOptions(barButtonItem: UIBarButtonItem, optionsType: OptionsType, optionsDelegate: OptionsDelegate) {
        let optionsVC = storyboard.instantiateViewController(withIdentifier: "optionsVC") as! OptionsViewController
        optionsVC.optionsDelegate = optionsDelegate
        optionsVC.modalPresentationStyle = .popover
        let height = optionsType == .GroupChat ? 150 : 60
        optionsVC.preferredContentSize = CGSize(width: 140, height: height)
        let popOver = optionsVC.popoverPresentationController
        popOver?.delegate = self
        popOver?.barButtonItem = barButtonItem
        
        self.navigationController.present(optionsVC, animated: true, completion: nil)
    }
    
    func presentAlertController(alertController: UIAlertController) {
        self.navigationController.present(alertController, animated: true, completion: nil)
    }
    
    func presentAllImagesCVC(messagesHistory: Results<MessageModel>, completion: (() -> Void)?) {
        let imagesCVC = storyboard.instantiateViewController(withIdentifier: "imagesCVC") as! ImagesCollectionViewController
        imagesCVC.messagesHistory = messagesHistory
        let navC = UINavigationController(rootViewController: imagesCVC)
        self.navigationController?.present(navC, animated: true, completion: completion)
    }
    
    func presentUIImagePicker(imgPickerDelegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate), completion: (() -> Void)?) {
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = imgPickerDelegate
        imgPicker.allowsEditing = false
        imgPicker.sourceType = .photoLibrary
        self.navigationController.present(imgPicker, animated: true, completion: completion)
    }
    
    func presentVoiceRecorder(voiceRecordeDelegate: VoiceRecorderInteractorDelegate, completion: (() -> Void)?) {
        let voiceRecordingVC = storyboard.instantiateViewController(withIdentifier: "VoiceRecordingVC") as! VoiceRecordingViewController
        voiceRecordingVC.voiceRecorderDelegate = voiceRecordeDelegate
        self.navigationController.present(voiceRecordingVC, animated: true, completion: completion)
    }
    
    func presentAvatars(chatRoom: ChatRoomModel) {
        let avatarChooseVC = storyboard.instantiateViewController(withIdentifier: "AvatarCollectionViewController") as! AvatarCollectionViewController_ChatRoom
        avatarChooseVC.chatRoom = chatRoom
        self.navigationController.present(avatarChooseVC, animated: true, completion: nil)
        
    }
    
    func pushVC(vc: UIViewController) {
        self.navigationController.pushViewController(vc, animated: true)
    }
}

extension ChatRouter: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
