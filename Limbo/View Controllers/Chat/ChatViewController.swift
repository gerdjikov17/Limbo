//
//  ChatViewController.swift
//  Limbo
//
//  Created by A-Team User on 25.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import Foundation
import UIKit
import MultipeerConnectivity
import RealmSwift

class ChatViewController: UIViewController {
    //    MARK: Properties
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextFieldBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var addPhotoButton: UIButton!
    var chatDelegate: UsersConnectivityDelegate?
    var userChattingWith: UserModel?
    var peerIDChattingWith: MCPeerID?
    var currentUser: UserModel?
    var messagesResults: Results<MessageModel>!
    var messages: [MessageModel]!
    var startIndex: Int! {
        get {
            var returnIndex = self.messagesResults.count - self.rangeOfMessagesToShow
            if returnIndex < 0 {
                returnIndex = 0
            }
            return returnIndex
        }
    }
    var selectedIndexPathForTimeStamp: IndexPath?
    var notificationToken: NotificationToken!
    var rangeOfMessagesToShow = 50
    
    //    MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.messagesResults = RealmManager.getMessagesForUsers(firstUser: self.currentUser!, secondUser: self.userChattingWith!)!
        self.messages = Array(self.messagesResults[startIndex...])
        self.chatTableView.dataSource = self
        self.chatTableView.delegate = self
        self.messageTextField.delegate = self;
        self.navigationItem.title = self.userChattingWith?.username
        let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
        if indexPath.row >= 0 {
            self.chatTableView.scrollToRow(at: indexPath, at: .middle, animated: false)
        }
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Options", style: .plain, target: self, action: #selector(self.optionsButtonTap))
        
        self.initNotificationToken()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
        if indexPath.row >= 0 {
            self.chatTableView.scrollToRow(at: indexPath, at: .middle, animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
//        self.notificationToken.invalidate()
    }
    
    //    MARK: Keyboard Notifications
    
    @objc func keyboardWillShow(notification: Notification) {
        let info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardHeight: CGFloat = keyboardSize.height
        let duration = info[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            if (self.messageTextFieldBottomConstraint.constant < 50) {
                self.messageTextFieldBottomConstraint.constant += keyboardHeight
                
            }
        }, completion: { (finished: Bool) in
            if self.messageTextFieldBottomConstraint.constant > 50 {
                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                if indexPath.row >= 0 {
                    self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
                }
            }
        })
        
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        let info = notification.userInfo!
        let duration = info[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.messageTextFieldBottomConstraint.constant = 5
        }, completion: { (finished: Bool) in
//            the next line reloads the data to resize the tableview and the cells
//            for unknown reason scrollToRow or setContentOffset doesn't work accordingly
            self.chatTableView.reloadData()
//            maybe this needs optimizing for better performance
        })
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    //    MARK: Button taps
    
    @objc func optionsButtonTap() {
        let optionsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "optionsVC") as! OptionsViewController
        optionsVC.optionsDelegate = self
        optionsVC.modalPresentationStyle = .popover
        let popOver = optionsVC.popoverPresentationController
        popOver?.delegate = self
        popOver?.barButtonItem = self.navigationItem.rightBarButtonItem
        
        present(optionsVC, animated: true, completion: nil)
        
    }
    
    @IBAction func sendButtonTap() {
        if (self.messageTextField.text?.count)! > 0 {
            guard var message = self.messageTextField.text else { return }
            
            if self.userChattingWith?.state == "Spectre" {
                self.sendMessageToSpectre(message: message)
            }
            else if message == UserDefaults.standard.string(forKey: Constants.UserDefaults.antiCurse) && userChattingWith?.uniqueDeviceID == UserDefaults.standard.string(forKey: Constants.UserDefaults.curseUserUniqueDeviceID){
                CurseManager.removeCurse()
                NotificationManager.shared.presentItemNotification(withTitle: "Anti-Spell", andText: "You removed your curse with anti-spell")
            }
            else if (self.peerIDChattingWith?.displayName.hasSuffix(".game"))! {
                self.sendMessageToGame(message: message)
            }
            else if message.count > 0 && self.currentUser!.curse != Curse.Silence.rawValue {
                if self.currentUser?.curse == Curse.Posession.rawValue {
                    message = message.shuffle()
                }
                self.sendMessageToUser(message: message, peerID: self.peerIDChattingWith!)
            }
            else if self.currentUser!.curse == Curse.Silence.rawValue{
                self.sendingMessageWhileSilenced()
            }
            
            self.messageTextField.text = ""
        }
    }
    
    @IBAction func addPhotoButtonTap(_ sender: AnyObject) {
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        imgPicker.allowsEditing = false
        imgPicker.sourceType = .photoLibrary
        self.present(imgPicker, animated: true, completion: nil)
    }
    
    @IBAction func itemsButtonTap(_ sender: AnyObject) {
        let button: UIButton = sender as! UIButton
//        using this hack because otherwise button.frame.origin.y is < 0 and popover is not visible
        button.frame = CGRect(x: button.frame.origin.x, y: self.sendButton.frame.origin.y, width: self.sendButton.frame.size.width, height: self.sendButton.frame.size.height)
        let itemsVC = storyboard?.instantiateViewController(withIdentifier: "itemsVC") as! ItemsViewController
        itemsVC.user = self.currentUser!
        itemsVC.modalPresentationStyle = .popover
        itemsVC.preferredContentSize = CGSize(width: 120, height: 70)
        let popoverPresentationController = itemsVC.popoverPresentationController
        popoverPresentationController?.permittedArrowDirections = .down
        popoverPresentationController!.sourceView = button
        popoverPresentationController!.sourceRect = button.bounds
        popoverPresentationController!.delegate = self
        self.navigationController?.present(itemsVC, animated: true, completion: nil)
    }
    
    func sendMessageToUser(message: String, peerID: MCPeerID) {
        let messageModel = MessageModel()
        messageModel.messageString = message
        messageModel.messageType = MessageType.Message.rawValue
        messageModel.sender = self.currentUser
        if let _ = self.chatDelegate?.sendMessage(messageModel: messageModel, toPeerID: peerID) {
            let realm = try! Realm()
            if let userChattingWith = RealmManager.userWith(uniqueID: (self.userChattingWith?.uniqueDeviceID)!, andUsername: (self.userChattingWith?.username)!) {
                try? realm.write {
                    realm.add(messageModel)
                    messageModel.receivers.append(userChattingWith)
                }
            }
        }
    }
    
    //    MARK: Other functions
    func initNotificationToken() {
        self.notificationToken = self.messagesResults.observe({ changes in
            switch changes {
            case .initial:
                self.chatTableView.reloadData()
            case .update(_, _, let insertions, _):
                
                self.chatTableView.beginUpdates()
                
                if insertions.count > 0 {
                    print("new insertion\n\n")
                    self.messages.append(self.messagesResults.last!)
                    self.chatTableView.insertRows(at: [IndexPath(row: self.messages.count - 1, section: 0)],
                                                  with: .automatic)
                }
                
                self.chatTableView.endUpdates()
                
                if insertions.count > 0 {
                    
                    self.chatTableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .middle, animated: true)
                }
            case .error(let error):
                print(error)
            }
        })
    }
    
}

// MARK: Protocol Conforms

extension ChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.sendButtonTap()
        return true
    }
}

extension ChatViewController: OptionsDelegate {
    func clearHistory() {
        let alertController = UIAlertController(title: "Clear history", message: "In a result of clearing your history you wont be able to recover it back.\nAre you sure you want to delete it ?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
            let realm = try! Realm()
            realm.beginWrite()
            if let results = RealmManager.getMessagesForUsers(firstUser: self.currentUser!, secondUser: self.userChattingWith!) {
                realm.delete(results)
            }
            try! realm.commitWrite()
            self.messages = Array(self.messagesResults)
            self.chatTableView.reloadData()
        }))
        alertController.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
            
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showImages() {
        let imagesCVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "imagesCVC") as! ImagesCollectionViewController
        imagesCVC.messagesHistory = self.messagesResults
        self.navigationController?.pushViewController(imagesCVC, animated: true)
    }
}

extension ChatViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationController(_ popoverPresentationController: UIPopoverPresentationController, willRepositionPopoverTo rect: UnsafeMutablePointer<CGRect>, in view: AutoreleasingUnsafeMutablePointer<UIView>) {
        print(rect)
    }
}

