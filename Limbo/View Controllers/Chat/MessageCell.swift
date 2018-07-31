//
//  MessageCell.swift
//  Limbo
//
//  Created by A-Team User on 25.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import Foundation
import UIKit

class MessageCell: UITableViewCell {
    @IBOutlet weak var receivedMessage: UITextView!
    @IBOutlet weak var sentMessage: UITextView!
    @IBOutlet weak var sentMessageTimestampLabel: UILabel!
    @IBOutlet weak var receivedMessageTimestampLabel: UILabel!
}
