//
//  UserModel.swift
//  Limbo
//
//  Created by A-Team User on 24.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import Foundation
import UIKit

class UserModel: NSObject {
    var username: String!
    var password: String!
    var avatar: UIImage!
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
    init(username: String) {
        self.username = username
    }
}
