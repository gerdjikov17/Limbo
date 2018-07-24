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
    
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var state: UILabel!
    
    func displayContent(avatar: UIImage, userModel: UserModel) {
        self.avatarImageView.image = avatar
        self.usernameLabel.text = userModel.username
    }
}
