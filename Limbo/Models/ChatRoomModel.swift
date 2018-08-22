//
//  ChatRoomModel.swift
//  Limbo
//
//  Created by A-Team User on 22.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit
import RealmSwift

class ChatRoomModel: Object {
    @objc dynamic var name = ""
    @objc dynamic var avatar = "ghost_avatar.png"
    let usersChattingWith = List<UserModel>()
}
