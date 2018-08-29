//
//  MessageCell.swift
//  Limbo
//
//  Created by A-Team User on 25.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import Foundation
import UIKit

class MessageCell: UITableViewCell, SetableForMessageModel {
    @IBOutlet weak var messageLabel: UITextView!
    @IBOutlet weak var messageTimestampLabel: UILabel!
    @IBOutlet weak var senderImageView: UIImageView!
    
    func set(forMessageModel message: MessageModel, senderImage: UIImage?) {
        self.messageLabel.text = message.messageString
        self.messageTimestampLabel.text = SmartFormatter.formatDate(date: message.timeSent)
        self.messageLabel.layer.masksToBounds = true;
        self.messageLabel.layer.cornerRadius = 5
        self.senderImageView?.image = senderImage
        
    }
}
