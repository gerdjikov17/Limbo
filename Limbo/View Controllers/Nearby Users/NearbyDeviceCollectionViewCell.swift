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
    
    func setCellContent(user: UserModel) {
        self.usernameLabel.text = user.username
        self.state.text = user.state
    }
}
