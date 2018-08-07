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
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextFieldBottomConstraint: NSLayoutConstraint!
    var chatDelegate: UsersConnectivityDelegate?
    var userChattingWith: UserModel?
    var peerIDChattingWith: MCPeerID?
    var currentUser: UserModel?
    var messages: [MessageModel]!
    var selectedIndexPathForTimeStamp: IndexPath?
    var lastLoadedMessageIndex: Int?
    var areAllMessagesLoaded: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.areAllMessagesLoaded = false
        self.messages = queryLastHundredMessages()
        self.chatTableView.dataSource = self
        self.chatTableView.delegate = self
        self.messageTextField.delegate = self;
        self.navigationItem.title = self.userChattingWith?.username
        let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
        if indexPath.row >= 0 {
            self.chatTableView.scrollToRow(at: indexPath, at: .middle, animated: false)
        }
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear history", style: .plain, target: self, action: #selector(self.clearHistoryButtonTap))
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
    }
    
    func queryLastHundredMessages() -> [MessageModel] {
        if let results = RealmManager.getMessagesForUsers(firstUser: self.currentUser!, secondUser: self.userChattingWith!) {
            if lastLoadedMessageIndex == nil {
                lastLoadedMessageIndex = results.count
            }
            if lastLoadedMessageIndex! - 50 >= 0 {
                let lastLoadedMessageIndex = self.lastLoadedMessageIndex!
                self.lastLoadedMessageIndex! -= 50
                return Array(results[lastLoadedMessageIndex - 50..<lastLoadedMessageIndex])
            }
            else {
                self.areAllMessagesLoaded = true
                return Array(results[0..<lastLoadedMessageIndex!])
            }
        }
        return Array()
    }
    
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
    
    @objc func clearHistoryButtonTap() {
        let alertController = UIAlertController(title: "Clear history", message: "In a result of clearing your history you wont be able to recover it back.\nAre you sure you want to delete it ?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
            let realm = try! Realm()
            realm.beginWrite()
            if let results = RealmManager.getMessagesForUsers(firstUser: self.currentUser!, secondUser: self.userChattingWith!) {
                realm.delete(results)
            }
            try! realm.commitWrite()
            self.messages = Array()
            self.chatTableView.reloadData()
        }))
        alertController.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
            
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func sendButtonTap() {
        
        if var message = self.messageTextField.text {
            if self.userChattingWith?.state == "Spectre" {
                self.sendMessageToSpectre(message: message)
            }
            else if message.count > 0 && self.currentUser!.curse != Curse.Silence.rawValue {
                if let peerID = self.peerIDChattingWith {
                    if self.currentUser?.curse == Curse.Posession.rawValue {
                        message = randomizeText(string: self.messageTextField.text!)
                    }
                    self.sendMessageToUser(message: message, peerID: peerID)
                }
            }
            else if self.currentUser!.curse == Curse.Silence.rawValue{
                self.sendingMessageWhileSilenced()
            }
            self.messageTextField.text = ""
        }
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
    
    func randomizeText(string: String) -> String {
        let shuffledString = string.sorted { (_, _) -> Bool in
            arc4random() < arc4random()
        }
        return String(shuffledString)
    }
    
    func sendMessageToUser(message: String, peerID: MCPeerID) {
        let messageModel = MessageModel()
        messageModel.messageString = message
        messageModel.sender = self.currentUser
        let success = self.chatDelegate?.sendMessage(messageModel: messageModel, toPeerID: peerID)
        if success! {
            self.messages.append(messageModel)
            let realm = try! Realm()
            if let userChattingWith = RealmManager.userWith(uniqueID: (self.userChattingWith?.uniqueDeviceID)!) {
                try? realm.write {
                    realm.add(messageModel)
                    messageModel.receivers.append(userChattingWith)
                }
                let indexOfMessage = self.messages.count - 1
                let indexPath = IndexPath(row: indexOfMessage, section: 0)
                self.chatTableView.insertRows(at: [indexPath], with: .middle)
                self.chatTableView.scrollToRow(at: indexPath, at: .middle, animated: true)
            }
        }
    }
}

extension ChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.sendButtonTap()
        return true
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

