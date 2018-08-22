//
//  NearbyUsersViewController+GroupChats.swift
//  Limbo
//
//  Created by A-Team User on 22.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import Foundation
import UIKit
import MultipeerConnectivity

extension NearbyUsersViewController {
    func addGroupChatCell() {
        guard !(self.users.keys.contains(where: { (peerID) -> Bool in
            peerID.displayName == "C"
        })) else {
            return
        }
        let groupChatUser = UserModel(username: "Create Group", state: "Group", uniqueDeviceID: "GroupChat")
        groupChatUser.userID = Constants.groupChatAddID
        groupChatUser.avatarString = "group_chat_add_icon.png"
        self.users[MCPeerID(displayName: "C")] = (user: groupChatUser, unreadMessages: 0)
    }
    
    func groupChatCellTap() {
        let allUsersTVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "allUsersTVC") as! AllUsersTableViewController
        allUsersTVC.users = self.users.compactMap({ (arg) -> UserModel? in
            
            let (_, value) = arg
            if value.user.userID == -1 {
                return value.user
            }
            return nil
        })
        self.navigationController?.pushViewController(allUsersTVC, animated: true)
    }
    
    func createGroupChat(withUsers users: [UserModel]) {
        
    }
}
