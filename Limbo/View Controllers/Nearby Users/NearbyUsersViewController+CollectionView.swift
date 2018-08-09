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
        
        var userModel: UserModel
        
        if self.currentUser != nil && itemsCountIfBlind == 1 && self.currentUser.curse == "Blind" {
            let userKV = self.users.first(where: { (key, value) -> Bool in
                key.displayName == "Spectre"
            })
            userModel = (userKV?.value)!
        }
        else {
            let allUsers = Array(self.users.values)
            userModel = allUsers[indexPath.row]
        }
        
        if userModel.state == "Tunak-Tunak-Tun" {
            cell.avatarImageView.image = #imageLiteral(resourceName: "tunak-tunak.jpg")
        }
        else if userModel.state == "Tic-Tac-Toe" {
            cell.avatarImageView.image = #imageLiteral(resourceName: "tic-tac-toe.png")
        }
        else if let defaultImage = UIImage(named: userModel.avatarString) {
            cell.avatarImageView.image = defaultImage
        }
        else {
            let imgurImage = try! UIImage(data: Data(contentsOf: URL(string: userModel.avatarString)!))
            cell.avatarImageView.image = imgurImage
        }
        cell.setCellContent(user: userModel)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedUser = Array(self.users.values)[indexPath.row]
        let selectedPeerID = Array(self.users.keys)[indexPath.row]
        self.usersConnectivity.inviteUser(peerID: selectedPeerID)
        let chatVC: ChatViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chatVC") as! ChatViewController
        chatVC.currentUser = self.currentUser
        chatVC.userChattingWith = selectedUser
        chatVC.peerIDChattingWith = selectedPeerID
        chatVC.chatDelegate = self.usersConnectivity
        self.usersConnectivity.chatDelegate = chatVC
        self.navigationController?.pushViewController(chatVC, animated: true)
        
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
