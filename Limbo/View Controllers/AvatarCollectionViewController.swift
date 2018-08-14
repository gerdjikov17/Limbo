//
//  AvatarCollectionViewController.swift
//  Limbo
//
//  Created by A-Team User on 27.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit

private let reuseIdentifier = "avatarCell"

class AvatarCollectionViewController: UICollectionViewController {

    var currentUser: UserModel?
    private var imageStrings: [String] = Array()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        imageStrings = self.readImagesFromResourcesFolder()
        
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(self.dismissSelf))
        gesture.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(gesture)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func readImagesFromResourcesFolder() -> [String] {
        return try! FileManager.default.contentsOfDirectory(atPath: Bundle.main.resourcePath!.appending("/Avatars/"))
    }
    

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageStrings.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        let backgroundView = UIImageView(frame: cell.frame)
        let image = UIImage(named: self.imageStrings[indexPath.row])
        backgroundView.image = image
        cell.backgroundView = backgroundView
        // Configure the cell
    
        return cell
    }
    
        // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.currentUser?.changeAvatar(newImageString: self.imageStrings[indexPath.row])
        self.dismiss(animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionFooter {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "footer", for: indexPath) as! AvatarCollectionReusableViewFooter
            footer.presentingVC = self
            return footer
        }
        return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "avatarHeader", for: indexPath)
    }

    @objc func dismissSelf() {
        self.dismiss(animated: true, completion: nil)
    }

}
