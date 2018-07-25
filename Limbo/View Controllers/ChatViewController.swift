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
    
    @objc func didTapOnMessage(recognizer: UITapGestureRecognizer) {
        let touchPoint = recognizer.location(in: self.chatTableView)
        let indexPath: IndexPath = self.chatTableView.indexPathForRow(at: touchPoint)!
        let messageModel = self.messages[indexPath.row]
        let cell: MessageCell
        if (messageModel.sender == self.currentUser) {
            cell = self.chatTableView.cellForRow(at: indexPath) as! MessageCell
            if cell.sentMessageTimestampLabel.alpha == 1.0 {
                UIView.animate(withDuration: 0.5) {
                    cell.sentMessageTimestampLabel.alpha = 0.0
                }
            }
            else {
                UIView.animate(withDuration: 0.5) {
                    cell.sentMessageTimestampLabel.alpha = 1.0
                }
            }
        }
        else {
            cell = self.chatTableView.cellForRow(at: indexPath) as! MessageCell
            if cell.receivedMessageTimestampLabel.alpha == 1.0  {
                UIView.animate(withDuration: 0.5) {
                    cell.receivedMessageTimestampLabel.alpha = 0.0
                }
            }
            else {
                UIView.animate(withDuration: 0.5) {
                    cell.receivedMessageTimestampLabel.alpha = 1.0
                }
            }
        }
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

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messageModel = self.messages[indexPath.row]
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let cell: MessageCell
        if (messageModel.sender == self.currentUser) {
            cell = tableView.dequeueReusableCell(withIdentifier: "sentMessageCell", for: indexPath) as! MessageCell
            cell.sentMessageLabel.text = self.messages[indexPath.row].messageString
            cell.sentMessageTimestampLabel.alpha = 0.0
            cell.sentMessageTimestampLabel.text = formatter.string(from: messageModel.timeSent)
            cell.sentMessageLabel.layer.masksToBounds = true;
            cell.sentMessageLabel.layer.cornerRadius = 5
            cell.sentMessageLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTapOnMessage(recognizer:))))
            
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: "receivedMessageCell", for: indexPath) as! MessageCell
            cell.receivedMessageLabel.text = self.messages[indexPath.row].messageString
            cell.receivedMessageTimestampLabel.alpha = 0.0
            cell.receivedMessageTimestampLabel.text = formatter.string(from: messageModel.timeSent)
            cell.receivedMessageLabel.layer.masksToBounds = true;
            cell.receivedMessageLabel.layer.cornerRadius = 5
            cell.receivedMessageLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTapOnMessage(recognizer:))))
        }
        
        return cell;
    }
}

extension ChatViewController: UITableViewDelegate {
    func calculateHeight(forMessage message: MessageModel) -> CGFloat {
        
        let messageString = message.messageString
        let attributes: [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 17.0)]
        
        let attributedString: NSAttributedString = NSAttributedString(string: messageString, attributes: attributes)
        
        let rect: CGRect = attributedString.boundingRect(with: CGSize(width: self.view.bounds.size.width - 20, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
        
        let requredSize: CGRect = rect
        return requredSize.height
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height: CGFloat = self.calculateHeight(forMessage: self.messages[indexPath.row])
        return height + 20.0
    }
}

