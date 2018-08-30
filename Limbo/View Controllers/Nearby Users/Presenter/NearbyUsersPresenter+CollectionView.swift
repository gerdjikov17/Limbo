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

extension NearbyUsersPresenter: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
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
