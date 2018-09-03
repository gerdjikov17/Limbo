//
//  AvatarCollectionViewController+ChatRoom.swift
//  Limbo
//
//  Created by A-Team User on 3.09.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit

class AvatarCollectionViewController_ChatRoom: AvatarCollectionViewController {
    var chatRoom: ChatRoomModel?
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let chatRoom = self.chatRoom {
            chatRoom.changeAvatar(newAvatar: self.imageStrings[indexPath.row])
        }
        self.dismiss(animated: true, completion: nil)
    }
}
