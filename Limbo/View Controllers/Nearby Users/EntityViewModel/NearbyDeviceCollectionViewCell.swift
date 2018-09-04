//
//  NearbyDeviceCollectionViewCell.swift
//  Limbo
//
//  Created by A-Team User on 24.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import Foundation
import UIKit

class NearbyDevicesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var state: UILabel!
    @IBOutlet weak var notSeenMessagesLabel: UILabel!
    
    
    func set(forChatRoomModelView modelView: ChatRoomModelView) {
        self.avatarImageView.image = self.getImage(forModelView: modelView)
        
        self.usernameLabel.text = modelView.name
        self.state.text = modelView.state
        if modelView.unreadMessages! > 0 {
            self.notSeenMessagesLabel.layer.cornerRadius = self.notSeenMessagesLabel.frame.size.height / 2
            self.notSeenMessagesLabel.clipsToBounds = true
            self.notSeenMessagesLabel.attributedText = NSAttributedString(string:
                String(" " + String(modelView.unreadMessages!) + " "),
                                                                          attributes:
                [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.backgroundColor: UIColor.red])
            
        }
        else {
            self.notSeenMessagesLabel.attributedText = NSAttributedString(string: "")
        }
    }
    
    private func getImage(forModelView chatRoom: ChatRoomModelView) -> UIImage {
        guard let roomType = chatRoom.roomType else { return #imageLiteral(resourceName: "ghost_avatar.png") }
        if roomType == RoomType.Tic_Tac_Toe {
            return #imageLiteral(resourceName: "tic-tac-toe.png")
        } else if roomType == RoomType.Tunak_Tunak {
            return #imageLiteral(resourceName: "tunak-tunak.jpg")
        } else if let defaultImage = UIImage(named: chatRoom.avatarString!) {
            return defaultImage
        } else {
            if let imgurImage = try! UIImage(data: Data(contentsOf: URL(string: chatRoom.avatarString!)!)) {
                return imgurImage
            }
            return #imageLiteral(resourceName: "ghost_avatar.png")
        }
    }
}
