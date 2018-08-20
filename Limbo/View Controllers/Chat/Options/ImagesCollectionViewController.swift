//
//  ImagesCollectionViewController.swift
//  Limbo
//
//  Created by A-Team User on 20.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit
import RealmSwift


class ImagesCollectionViewController: UICollectionViewController {

    var messagesHistory: Results<MessageModel>!
    var images_Senders: [(image: UIImage, sender: String?)]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        images_Senders = Array()
        getImagesFromMessageHistory()
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

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
