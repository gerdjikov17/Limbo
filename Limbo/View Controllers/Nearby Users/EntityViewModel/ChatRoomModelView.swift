//
//  ChatRoomModelView.swift
//  Limbo
//
//  Created by A-Team User on 28.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit

class ChatRoomModelView: NSObject {
    var name: String?
    var state: String?
    var unreadMessages: Int?
    var avatarString: String?
    var roomType: RoomType?
    
    init(chatRoom: ChatRoomModel, unreadMessages: Int, state: String) {
        self.name = chatRoom.name
        self.state = state
        self.unreadMessages = unreadMessages
        self.avatarString = chatRoom.avatar
        self.roomType = RoomType(rawValue: chatRoom.roomType)
    }
}
