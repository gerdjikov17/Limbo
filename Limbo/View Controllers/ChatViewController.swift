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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.messages = Array()
        self.chatTableView.dataSource = self
        self.chatTableView.delegate = self
        self.navigationItem.title = self.userChattingWith?.username
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        let info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardHeight: CGFloat = keyboardSize.height
        let duration = info[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            if (self.messageTextFieldBottomConstraint.constant < 50) {
                self.messageTextFieldBottomConstraint.constant += keyboardHeight
            }
        }, completion: nil)
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        let info = notification.userInfo!
        let duration = info[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.messageTextFieldBottomConstraint.constant = 5
        }, completion: nil)
    }
    
    @IBAction func sendButtonTap() {
        if let message = self.messageTextField.text {
            if message.count > 0 {
                if let peerID = self.peerIDChattingWith {
                    
                    let messageModel = MessageModel()
                    messageModel.messageString = message
                    messageModel.sender = self.currentUser
                    
                
                    
                    self.messages.append(messageModel)
                    let indexOfMessage = self.messages.count - 1
                    let indexPath = IndexPath(row: indexOfMessage, section: 0)
                    self.chatTableView.insertRows(at: [indexPath], with: .middle)
                    self.chatTableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                    self.chatDelegate?.sendMessage(messageModel: messageModel, toPeerID: peerID)
                    self.messageTextField.text = ""
                }
            }
        }
    }
}

extension ChatViewController: ChatDelegate {
    func didReceiveMessage(messageModel: MessageModel, fromPeerID: MCPeerID) {
        if fromPeerID == self.peerIDChattingWith {
            self.messages.append(messageModel)
            let indexOfMessage = self.messages.count - 1
            let indexPath = IndexPath(row: indexOfMessage, section: 0)
            DispatchQueue.main.async {
                self.chatTableView.insertRows(at: [indexPath], with: .middle)
                self.chatTableView.scrollToRow(at: indexPath, at: .middle, animated: true)
            }
        }
    }
}

