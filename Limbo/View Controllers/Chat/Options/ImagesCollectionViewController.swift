//
//  ImagesCollectionViewController.swift
//  Limbo
//
//  Created by A-Team User on 20.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit
import RealmSwift


class ImagesCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var messagesHistory: Results<MessageModel>!
    var images_Senders: [(image: UIImage, sender: String?)]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        images_Senders = Array()
        self.images_Senders = RealmManager.getImagesFromMessageHistory(messageHistory: messagesHistory)
        self.definesPresentationContext = true
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(dismisSelf))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func dismisSelf() {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return images_Senders.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewImageCell", for: indexPath) as! ImageCollectionViewCell
        cell.imageView.image = images_Senders[indexPath.row].image
        return cell
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imageVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chatImageVC") as! ChatImageViewController
        imageVC.currentPhotoIndex = indexPath.row
        imageVC.photoMessages = messagesHistory
        self.present(imageVC, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width - 6)  / 3, height: (UIScreen.main.bounds.width - 6)  / 3)
    }


}
