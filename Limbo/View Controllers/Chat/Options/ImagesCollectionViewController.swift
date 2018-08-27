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
        getImagesFromMessageHistory()
        self.definesPresentationContext = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getImagesFromMessageHistory() {
        let limboDirectory = FileManager.getDocumentsDirectory().appendingPathComponent("Limbo", isDirectory: false)
        for message in messagesHistory {
            if let image = ImageCache.shared.getImage(forKey: (message.messageString as NSString)) {
                images_Senders.append((image: image, sender: message.sender?.username))
                print("gets data from the cache")
            }
            else {
                let filePath = limboDirectory.appendingPathComponent(message.messageString, isDirectory: false)
                if let imageData = try? Data(contentsOf: filePath) {
                    if let image = UIImage(data: imageData) {
                        ImageCache.shared.cacheImage(image: image, forKey: (message.messageString as NSString))
                        images_Senders.append((image: image, sender: message.sender?.username))
                    }
                }
            }
        }
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
        let image = images_Senders[indexPath.row].image
        let imageVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chatImageVC") as! ChatImageViewController
        imageVC.image = image
        imageVC.senderUsername = images_Senders[indexPath.row].sender!
        self.present(imageVC, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width - 6)  / 3, height: (UIScreen.main.bounds.width - 6)  / 3)
    }


}
