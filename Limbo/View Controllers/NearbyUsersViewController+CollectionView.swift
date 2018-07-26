//
//  NearbyUsersViewController+CollectionView.swift
//  Limbo
//
//  Created by A-Team User on 26.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import Foundation
import UIKit

extension NearbyUsersViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NearbyUserCell", for: indexPath) as! NearbyDevicesCollectionViewCell
        let allUsers = Array(self.users.values)
        let userModel = allUsers[indexPath.row]
        let image = UIImage(named: "ghost_avatar.png")
        cell.avatarImageView.image = image;
        cell.setCellContent(user: userModel)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedUser = Array(self.users.values)[indexPath.row]
        let selectedPeerID = Array(self.users.keys)[indexPath.row]
        let chatVC: ChatViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chatVC") as! ChatViewController
        chatVC.currentUser = self.currentUser
        chatVC.userChattingWith = selectedUser
        chatVC.peerIDChattingWith = selectedPeerID
        chatVC.chatDelegate = self.usersConnectivity
        self.usersConnectivity.chatDelegates?.append(chatVC)
        self.navigationController?.pushViewController(chatVC, animated: true)
        
        
    }
}