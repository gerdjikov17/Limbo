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
import DZNEmptyDataSet
import RealmSwift

class NearbyUsersViewController: UIViewController {

    var currentUser: UserModel!
    var users: [MCPeerID: UserModel]!
    var usersConnectivity: UsersConnectivity!
    @IBOutlet weak var nearbyUsersCollectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.users = Dictionary()
        
        self.nearbyUsersCollectionView.emptyDataSetSource = self;
        self.nearbyUsersCollectionView.emptyDataSetDelegate = self;
        
        if !UserDefaults.standard.bool(forKey: Constants.UserDefaults.isLoged) {
            let loginVC: LoginViewController = storyboard?.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
            loginVC.loginDelegate = self
            self.present(loginVC, animated: true, completion: nil)
        }
        else {
            let realm = try! Realm()
            self.currentUser = realm.objects(UserModel.self).filter("username = %@", UserDefaults.standard.string(forKey: Constants.UserDefaults.loggedUserName)!).first!
            self.usersConnectivity = UsersConnectivity(userModel: currentUser)
            self.usersConnectivity.delegate = self;
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

}

extension NearbyUsersViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NearbyUserCell", for: indexPath) as! NearbyDevicesCollectionViewCell
        let allUsers = Array(self.users.values)
        let userModel = allUsers[indexPath.row]
        let imageURL = URL(string: "https://movies4maniacs.liberty.me/wp-content/uploads/sites/1218/2015/09/avatarsucks.jpg")
        let imageData = try? Data(contentsOf: imageURL!)
        let image = UIImage(data: imageData!)
        cell.displayContent(avatar: image!, userModel: userModel)
        
        return cell
    }
}

extension NearbyUsersViewController: NearbyUsersDelegate {
   
    func didLostUser(user: UserModel, peerID: MCPeerID) {
        self.users.removeValue(forKey: peerID)
        self.nearbyUsersCollectionView.reloadData()
    }
    
    func didFindNewUser(user: UserModel, peerID: MCPeerID) {
        self.users[peerID] = user
        self.nearbyUsersCollectionView.reloadData()
    }
    
}

extension NearbyUsersViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "No limbos near you!\nLooking for limbos")
    }
}

extension NearbyUsersViewController: LoginDelegate {
    func didLogin(userModel: UserModel) {
        self.currentUser = userModel
        self.usersConnectivity = UsersConnectivity(userModel: currentUser)
        self.usersConnectivity.delegate = self;
        self.dismiss(animated: true, completion: nil)
    }
    
}
