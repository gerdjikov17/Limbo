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
    @IBOutlet weak var currentUserImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userStateLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.users = Dictionary()
        
        navigationController?.navigationBar.barTintColor = UIColor(red:0.02, green:0.11, blue:0.16, alpha:0.5)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        
        self.nearbyUsersCollectionView.emptyDataSetSource = self;
        self.nearbyUsersCollectionView.emptyDataSetDelegate = self;
        
        if !UserDefaults.standard.bool(forKey: Constants.UserDefaults.isLoged) {
            let loginVC: LoginViewController = storyboard?.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
            loginVC.loginDelegate = self
            self.present(loginVC, animated: true, completion: nil)
        }
        else {
            let realm = try! Realm()
            self.currentUser = realm.objects(UserModel.self).filter("userID = %d", UserDefaults.standard.integer(forKey: Constants.UserDefaults.loggedUserID)).first!
            self.usersConnectivity = UsersConnectivity(userModel: currentUser)
            self.usersConnectivity.delegate = self;
            self.setUIContent(userModel: self.currentUser)
        }
        NotificationCenter.default.addObserver(self, selector: Selector(("batteryLevelDidChange:")), name: NSNotification.Name.UIDeviceBatteryLevelDidChange, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func batteryLevelDidChange(notification: NSNotification) {
        let batteryLevel = UIDevice.current.batteryLevel
        self.currentUser.setState(batteryLevel: batteryLevel)
        self.userStateLabel.text = self.currentUser.state
    }
    
    func setUIContent(userModel: UserModel) {
        self.currentUserImageView.image = UIImage(named: "ghost_avatar.png")
        self.usernameLabel.text = userModel.username
        self.userStateLabel.text = userModel.state
    }

}

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

extension NearbyUsersViewController: NearbyUsersDelegate {
   
    func didLostUser(peerID: MCPeerID) {
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
        return NSAttributedString(string: "No one is in the limbo\nLooking for someone")
    }
}

extension NearbyUsersViewController: LoginDelegate {
    func didLogin(userModel: UserModel) {
        self.currentUser = userModel
        self.usersConnectivity = UsersConnectivity(userModel: currentUser)
        self.usersConnectivity.delegate = self;
        self.setUIContent(userModel: self.currentUser)
        UserDefaults.standard.set(true, forKey: Constants.UserDefaults.isLoged)
        UserDefaults.standard.set(userModel.userID, forKey: Constants.UserDefaults.loggedUserID)
        UserDefaults.standard.synchronize()
        self.dismiss(animated: true, completion: nil)
    }
    
}
