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

extension ChatPresenter: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.chatPresenter.getMessages().count
        return self.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let messageModel = self.chatPresenter.getMessages()[indexPath.row]
        let messageModel = self.messages[indexPath.row]
        let senderImage: UIImage? = self.image(forMessage: messageModel, andIndexPath: indexPath)
        let cell = MessageCellsManager.properCell(forMessageModel: messageModel, indexPath: indexPath,
                                                  tableView: tableView, target: self.chatView)
        cell.set(forMessageModel: messageModel, senderImage: senderImage)
        return cell
    }
}

extension ChatPresenter: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y == 0 {
            self.requestMoreMessages()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = self.messages[indexPath.row]
        if message.messageType == MessageType.Message.rawValue {
            let height: CGFloat = MessageCellsManager.calculateHeight(forMessage: self.messages[indexPath.row])
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

