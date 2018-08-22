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
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NearbyUserCell", for: indexPath) as! NearbyDevicesCollectionViewCell
        let userModelAndUnreadMessages = getUserModelAndUnreadMessages(forIndexPath: indexPath)
        let userModel = userModelAndUnreadMessages.userModel
        let unreadMessages = userModelAndUnreadMessages.unreadMessages
        cell.avatarImageView.image = self.getImageForUser(userModel: userModel)

        cell.usernameLabel.text = userModel.username
        cell.state.text = userModel.state
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
        let selectedUser = getUserModelAndUnreadMessages(forIndexPath: indexPath)
        
        guard selectedUser.userModel.userID != Constants.groupChatAddID else {
            self.groupChatCellTap()
            return
        }
        
        let selectedPeerID = Array(self.users.keys)[indexPath.row]
        self.lastSelectedPeerID = selectedPeerID
        self.usersConnectivity.inviteUser(peerID: selectedPeerID)
        let chatVC: ChatViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chatVC") as! ChatViewController
        chatVC.currentUser = self.currentUser
        chatVC.userChattingWith = selectedUser.userModel
        chatVC.peerIDChattingWith = selectedPeerID
        chatVC.chatDelegate = self.usersConnectivity
        
        self.users[selectedPeerID]? = (selectedUser.userModel, 0)
        
        self.navigationController?.pushViewController(chatVC, animated: true)
        
    }
    
    //    MARK: Cell content help functions
    
    private func getUserModelAndUnreadMessages(forIndexPath indexPath: IndexPath) -> (userModel: UserModel, unreadMessages: Int) {
        if self.currentUser != nil && itemsCountIfBlind == 1 && self.currentUser.curse == "Blind" {
            let userKV = self.users.first(where: { (key, value) -> Bool in
                key.displayName == "Spectre"
            })
            return ((userKV?.value)!.user, (userKV?.value)!.unreadMessages)
        }
        else {
            let allUsers = Array(self.users.values)
            return (allUsers[indexPath.row].user, allUsers[indexPath.row].unreadMessages)
        }
    }
    
    private func getImageForUser(userModel: UserModel) -> UIImage {
        if userModel.state == "Tunak-Tunak-Tun" {
            return #imageLiteral(resourceName: "tunak-tunak.jpg")
        }
        else if userModel.state == "Tic-Tac-Toe" {
            return #imageLiteral(resourceName: "tic-tac-toe.png")
        }
        else if let defaultImage = UIImage(named: userModel.avatarString) {
            return defaultImage
        }
        else {
            if let imgurImage = try! UIImage(data: Data(contentsOf: URL(string: userModel.avatarString)!)) {
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
