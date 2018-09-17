//
//  MessageCellsManager.swift
//  Limbo
//
//  Created by A-Team User on 28.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit

class MessageCellsManager: NSObject {
    static func properCell(forMessageModel message: MessageModel, indexPath: IndexPath, tableView: UITableView, target: ChatViewInterface) -> (UITableViewCell & SetableForMessageModel) {
        switch message.messageType {
        case MessageType.Message.rawValue:
            
            let identifier = message.sender == RealmManager.currentLoggedUser() ? sentMessageCellIdentifier : receivedMessageCellIdentifier
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! MessageCell
            cell.messageLabel.addGestureRecognizer(UITapGestureRecognizer(target: target, action: #selector(target.didTapOnMessage(recognizer:))))
            return cell
            
        case MessageType.Photo.rawValue:
            let identifier = message.sender == RealmManager.currentLoggedUser() ? sentPhotoCellIdentifier : receivedPhotoCellIdentifier
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! PhotoTableViewCell
            cell.sentPhotoImageView.addGestureRecognizer(UITapGestureRecognizer(target: target, action: #selector(target.didTapOnImage(recognizer:))))
            return cell
            
        case MessageType.Voice_Record.rawValue:
            let identifier = message.sender == RealmManager.currentLoggedUser() ? sentVoiceMessageCellIdentifier : receivedVoiceMessageCellIdentifier
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! VoiceMessageTableViewCell  
            return cell
            
        default:
            return tableView.dequeueReusableCell(withIdentifier: sentMessageCellIdentifier, for: indexPath) as! MessageCell
        }
    }
    
    static func calculateHeight(forMessage message: MessageModel, forViewSize size: CGSize) -> CGFloat {
        
        let messageString = message.messageString
        let attributes: [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14.0)]
        
        let attributedString: NSAttributedString = NSAttributedString(string: messageString, attributes: attributes)
        
        let rect: CGRect = attributedString.boundingRect(with: CGSize(width: size.width - 53, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
        
        let requredSize: CGRect = rect
        return requredSize.height + 16
    }
}

