//
//  ChatViewController+TableView.swift
//  Limbo
//
//  Created by A-Team User on 26.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import Foundation
import UIKit

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
            cell.sentMessage.text = self.messages[indexPath.row].messageString
            cell.sentMessageTimestampLabel.text = formatter.string(from: messageModel.timeSent)
            cell.sentMessage.layer.masksToBounds = true;
            cell.sentMessage.layer.cornerRadius = 5
            cell.sentMessage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTapOnMessage(recognizer:))))
            
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: "receivedMessageCell", for: indexPath) as! MessageCell
            cell.receivedMessage.text = self.messages[indexPath.row].messageString
            cell.receivedMessageTimestampLabel.text = formatter.string(from: messageModel.timeSent)
            cell.receivedMessage.layer.masksToBounds = true;
            cell.receivedMessage.layer.cornerRadius = 5
            cell.receivedMessage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTapOnMessage(recognizer:))))
        }
        
        return cell;
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
        
        if indexPath.row == self.messages.count - 1 {
            self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y == 0 && !self.areAllMessagesLoaded{
            let newResultsOfMessages = queryLastHundredMessages()
            let mergedArray = newResultsOfMessages + messages
            self.messages = mergedArray
            chatTableView.reloadData()
            
            let indexPath = IndexPath(item: newResultsOfMessages.count, section: 0)
            self.chatTableView.scrollToRow(at: indexPath, at: .top, animated: false)
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
        let height: CGFloat = self.calculateHeight(forMessage: self.messages[indexPath.row])
        if self.selectedIndexPathForTimeStamp != nil && self.selectedIndexPathForTimeStamp == indexPath {
            return height + 17
        }
        return height + 6
    }

}
