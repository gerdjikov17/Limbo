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

extension NearbyUsersViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NearbyUserCell", for: indexPath) as! NearbyDevicesCollectionViewCell
        let allUsers = Array(self.users.values)
        let userModel = allUsers[indexPath.row]
        cell.avatarImageView.image = UIImage(named: userModel.avatarString)
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

extension NearbyUsersViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "No one is in the limbo\nLooking for someone")
    }
}
