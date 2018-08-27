//
//  NearbyUsersViewController+CollectionView.swift
//  Limbo
//
//  Created by A-Team User on 26.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import Foundation
import UIKit
import DZNEmptyDataSet
import RealmSwift

extension NearbyUsersViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let user = RealmManager.currentLoggedUser() {
            if user.curse == "Blind" {
                return itemsCountIfBlind
            }
        }
        return chatRooms.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NearbyUserCell", for: indexPath) as! NearbyDevicesCollectionViewCell
        let userModelAndUnreadMessages = getUserModelAndUnreadMessages(forIndexPath: indexPath)
        let chatRoom = userModelAndUnreadMessages.chatRoom
        let unreadMessages = userModelAndUnreadMessages.unreadMessages
        cell.avatarImageView.image = self.getImage(forChatRoom: chatRoom)

        cell.usernameLabel.text = chatRoom.name
        cell.state.text = chatRoom.usersChattingWith.count > 1 ? "Group Chat" : chatRoom.usersChattingWith.first?.state
        if unreadMessages > 0 {
            cell.notSeenMessagesLabel.layer.cornerRadius = cell.notSeenMessagesLabel.frame.size.height / 2
            cell.notSeenMessagesLabel.clipsToBounds = true
            cell.notSeenMessagesLabel.attributedText = NSAttributedString(string: String(" " + String(unreadMessages) + " "), attributes: [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.backgroundColor: UIColor.red])
            
        }
        else {
            cell.notSeenMessagesLabel.attributedText = NSAttributedString(string: "")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedRoom = getUserModelAndUnreadMessages(forIndexPath: indexPath)
        
        guard selectedRoom.chatRoom.roomType != RoomType.CreateGroupChat.rawValue else {
            self.groupChatCellTap()
            return
        }
        
        let selectedPeerID = Array(self.chatRooms.keys)[indexPath.row]
        self.lastSelectedChatRoomUUID = selectedRoom.chatRoom.uuid
        self.usersConnectivity.inviteUser(peerID: selectedPeerID)
        
        let view = ChatRouter.createChatModule(using: self.navigationController!, usersConnectivityDelegate: self.usersConnectivity, chatRoom: selectedRoom.chatRoom)
        
        self.chatRooms[selectedPeerID]?.unreadMessages = 0
        
        self.navigationController?.pushViewController(view, animated: true)
        
    }
    
    //    MARK: Cell content help functions
    
    private func getUserModelAndUnreadMessages(forIndexPath indexPath: IndexPath) -> (chatRoom: ChatRoomModel, unreadMessages: Int) {
        if self.currentUser != nil && itemsCountIfBlind == 1 && self.currentUser.curse == "Blind" {
            let userKV = self.chatRooms.first(where: { (key, value) -> Bool in
                key.displayName == "Spectre"
            })
            return ((userKV?.value)!.chatRoom, (userKV?.value)!.unreadMessages)
        }
        else {
            let allUsers = Array(self.chatRooms.values)
            return (allUsers[indexPath.row].chatRoom, allUsers[indexPath.row].unreadMessages)
        }
    }
    
    private func getImage(forChatRoom chatRoom: ChatRoomModel) -> UIImage {
        if chatRoom.roomType == RoomType.Game.rawValue {
            return #imageLiteral(resourceName: "tic-tac-toe.png")
        }
//            to do appropriate game avatar
        else if let defaultImage = UIImage(named: chatRoom.avatar) {
            return defaultImage
        }
        else {
            if let imgurImage = try! UIImage(data: Data(contentsOf: URL(string: chatRoom.avatar)!)) {
                return imgurImage
            }
            return #imageLiteral(resourceName: "ghost_avatar.png")
        }
    }

}

extension NearbyUsersViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "No one is in the limbo\nLooking for someone")
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        let image = #imageLiteral(resourceName: "ghost_avatar.png")
        var newWidth: CGFloat
        if UIDevice.current.userInterfaceIdiom == .pad {
            newWidth = 200
        }
        else {
            newWidth = 100
        }
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight), blendMode: .normal, alpha: 0.5)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
