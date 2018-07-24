//
//  NearbyUsersViewController.swift
//  Limbo
//
//  Created by A-Team User on 24.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import Foundation
import UIKit
import MultipeerConnectivity

class NearbyUsersViewController: UIViewController, UICollectionViewDelegate {

    var users: [UserModel]!
    var usersIDs: [MCPeerID]!
    let usersConnectivity: UsersConnectivity! = UsersConnectivity()
    @IBOutlet weak var nearbyUsersCollectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.users = Array()
        self.usersIDs = Array()
        self.usersConnectivity.delegate = self;
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

}

extension NearbyUsersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NearbyUserCell", for: indexPath) as! NearbyDevicesCollectionViewCell
        let userModel = self.users[indexPath.row]
        let imageURL = URL(string: "https://movies4maniacs.liberty.me/wp-content/uploads/sites/1218/2015/09/avatarsucks.jpg")
        let imageData = try? Data(contentsOf: imageURL!)
        let image = UIImage(data: imageData!)
        cell.displayContent(avatar: image!, userModel: userModel)
        
        return cell
    }
}

extension NearbyUsersViewController: NearbyUsersDelegate {
   
    func didLostUser(user: UserModel, peerID: MCPeerID) {
        if let index = self.usersIDs.index(of: peerID) {
            self.usersIDs.remove(at: index)
            self.users.remove(at: index)
            self.nearbyUsersCollectionView.reloadData()
        }
    }
    
    func didFindNewUser(user: UserModel, peerID: MCPeerID) {
        self.usersIDs.append(peerID)
        self.users.append(user)
        self.nearbyUsersCollectionView.reloadData()
    }
    
    
}
