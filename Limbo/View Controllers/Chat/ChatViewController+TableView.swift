//
//  ChatViewController+TableView.swift
//  Limbo
//
//  Created by A-Team User on 26.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import Foundation
import UIKit

let sentMessageCellIdentifier = "sentMessageCell"
let receivedMessageCellIdentifier = "receivedMessageCell"
let sentPhotoCellIdentifier = "sentPhotoCell"
let receivedPhotoCellIdentifier = "receivedPhotoCell"
let sentVoiceMessageCellIdentifier = "sentVoiceMessage"
let receivedVoiceMessageCellIdentifier = "receivedVoiceMessage"

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatPresenter.getMessages().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messageModel = self.chatPresenter.getMessages()[indexPath.row]
        var mainCell: UITableViewCell

        let senderImage: UIImage? = self.chatPresenter.image(forMessage: messageModel, andIndexPath: indexPath)
        
        switch messageModel.messageType {
        case MessageType.Message.rawValue:
            
            let identifier = messageModel.sender == RealmManager.currentLoggedUser() ? sentMessageCellIdentifier : receivedMessageCellIdentifier
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! MessageCell
            cell.messageLabel.text = self.chatPresenter.getMessages()[indexPath.row].messageString
            cell.messageTimestampLabel.text = SmartFormatter.formatDate(date: messageModel.timeSent)
            cell.messageLabel.layer.masksToBounds = true;
            cell.messageLabel.layer.cornerRadius = 5
            cell.messageLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTapOnMessage(recognizer:))))
            cell.senderImageView?.image = senderImage
            mainCell = cell
            
        case MessageType.Photo.rawValue:
            let identifier = messageModel.sender == RealmManager.currentLoggedUser() ? sentPhotoCellIdentifier : receivedPhotoCellIdentifier
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! PhotoTableViewCell
            cell.setCellUI(forMessageModel: messageModel)
            cell.sentPhotoImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTapOnImage(recognizer:))))
            cell.senderImageView?.image = senderImage
            mainCell = cell
            
        case MessageType.Voice_Record.rawValue:
            let identifier = messageModel.sender == RealmManager.currentLoggedUser() ? sentVoiceMessageCellIdentifier : receivedVoiceMessageCellIdentifier
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! VoiceMessageTableViewCell
            cell.initialConfiguration(message: messageModel)
            cell.voiceProgressView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTapOnMessage(recognizer:))))
            cell.senderImageView?.image = senderImage
            mainCell = cell
            
        default:
            mainCell = tableView.dequeueReusableCell(withIdentifier: sentMessageCellIdentifier, for: indexPath) as! MessageCell
        }
        
        
        return mainCell;
    }
}

extension ChatViewController: UITableViewDelegate {
    
    @objc private func didTapOnMessage(recognizer: UITapGestureRecognizer) {
        let touchPoint = recognizer.location(in: self.chatTableView)
        let indexPath: IndexPath = self.chatTableView.indexPathForRow(at: touchPoint)!
        
        self.chatTableView.beginUpdates()
        
        if self.selectedIndexPathForTimeStamp == indexPath {
            self.selectedIndexPathForTimeStamp = nil
        }
        else {
            self.selectedIndexPathForTimeStamp = indexPath
        }
        self.chatTableView.endUpdates()
        
        if indexPath.row == self.chatPresenter.getMessages().count - 1 {
            self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y == 0 {
            self.chatPresenter.requestMoreMessages()
        }
    }
    
    private func calculateHeight(forMessage message: MessageModel) -> CGFloat {
        
        let messageString = message.messageString
        let attributes: [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14.0)]
        
        let attributedString: NSAttributedString = NSAttributedString(string: messageString, attributes: attributes)
        
        let rect: CGRect = attributedString.boundingRect(with: CGSize(width: self.view.frame.size.width - 53, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
        
        let requredSize: CGRect = rect
        return requredSize.height + 16
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = self.chatPresenter.getMessages()[indexPath.row]
        if message.messageType == MessageType.Message.rawValue {
            let height: CGFloat = self.calculateHeight(forMessage: self.chatPresenter.getMessages()[indexPath.row])
            if self.selectedIndexPathForTimeStamp != nil && self.selectedIndexPathForTimeStamp == indexPath {
                return height + 17
            }
            return height + 6
        }
        else if message.messageType == MessageType.Voice_Record.rawValue {
            return 40
        }
        else {
            return 155
        }
        
    }

}

