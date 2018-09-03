//
//  NearbyUsersPresenter+CollectionView.swift
//  Limbo
//
//  Created by A-Team User on 28.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//


import Foundation
import UIKit
import DZNEmptyDataSet
import RealmSwift

extension NearbyUsersPresenter: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.numberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NearbyUserCell", for: indexPath) as! NearbyDevicesCollectionViewCell
        let modelView = self.chatRoomModelView(forIndexPath: indexPath)
        cell.set(forChatRoomModelView: modelView)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.didSelectItem(atIndexPath: indexPath)
    }
    
    //    MARK: Cell content help functions
}
