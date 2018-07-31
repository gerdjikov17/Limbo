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
import LNRSimpleNotifications

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
        
        let realm = try! Realm()
        let results = realm.objects(MessageModel.self).filter("(sender = %@ AND ANY receivers.username = %@) OR (sender.username = %@ AND ANY receivers.username = %@)", self.currentUser!, self.userChattingWith!.username, self.userChattingWith!.username, self.currentUser!.username)
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
    
    @objc func clearHistoryButtonTap() {
        let alertController = UIAlertController(title: "Clear history", message: "In result of clearing your history you wont be able to recover it back.\nAre you sure you want to delete it ?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            let realm = try! Realm()
            realm.beginWrite()
            let results = realm.objects(MessageModel.self).filter("(sender = %@ AND ANY receivers.username = %@) OR (sender.username = %@ AND ANY receivers.username = %@)", self.currentUser!, self.userChattingWith!.username, self.userChattingWith!.username, self.currentUser!.username)
            realm.delete(results)
            try! realm.commitWrite()
            self.messages = Array()
            self.chatTableView.reloadData()
        }))
        alertController.addAction(UIAlertAction(title: "No", style: .destructive, handler: { (action) in
            
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func sendButtonTap() {
        if let message = self.messageTextField.text {
            if message.count > 0 && self.currentUser!.curse != .Silence {
                if let peerID = self.peerIDChattingWith {
                    
                    let messageModel = MessageModel()
                    if self.currentUser?.curse == Curse.Posession {
                        messageModel.messageString = randomizeText(string: self.messageTextField.text!)
                    }
                    else {
                        messageModel.messageString = message
                    }
                    messageModel.sender = self.currentUser
                    
                    let success = self.chatDelegate?.sendMessage(messageModel: messageModel, toPeerID: peerID)
                    if success! {
                        self.messages.append(messageModel)
                        let realm = try! Realm()
                        let userChattingWith = realm.objects(UserModel.self).filter("username == %@", self.userChattingWith!.username).first
                        try? realm.write {
                            realm.add(messageModel)
                            messageModel.receivers.append(userChattingWith!)
                            
                            let indexOfMessage = self.messages.count - 1
                            let indexPath = IndexPath(row: indexOfMessage, section: 0)
                            self.chatTableView.insertRows(at: [indexPath], with: .middle)
                            self.chatTableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                        }
                    }
                }
            }
            else {
                let pointForToast = CGPoint(x: self.view.center.x, y: (self.navigationController?.navigationBar.frame.size.height)! + CGFloat(100))
                let lastCurseDate = UserDefaults.standard.object(forKey: Constants.UserDefaults.lastCurseDate) as! Date
                let timeInterval = Date.timeIntervalSince(Date())
                let remainingTime = Constants.Curses.curseTime - timeInterval(lastCurseDate)
                let curseRemainingTime = Int(remainingTime)
                self.view.makeToast("You are cursed with Silence", point: pointForToast, title: "You can't chat with people for \(curseRemainingTime) seconds", image: #imageLiteral(resourceName: "ghost_avatar.png"), completion: nil)
            }
            self.messageTextField.text = ""
        }
    }
    
    func randomizeText(string: String) -> String {
        let shuffledString = string.sorted { (_, _) -> Bool in
            arc4random() < arc4random()
        }
        return String(shuffledString)
    }
}

extension ChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.sendButtonTap()
        return true
    }
}

