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
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign out", style: .plain, target: self, action: #selector(self.signOutButtonTap))
        
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
            self.currentUser.setState(batteryLevel: UIDevice.current.batteryLevel)
            self.usersConnectivity = UsersConnectivity(userModel: currentUser)
            self.usersConnectivity.delegate = self;
            self.setUIContent(userModel: self.currentUser)
        }
        NotificationCenter.default.addObserver(self, selector: Selector(("batteryLevelDidChange:")), name: NSNotification.Name.UIDeviceBatteryLevelDidChange, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func batteryLevelDidChange(notification: NSNotification) {
        let batteryLevel = UIDevice.current.batteryLevel
        self.currentUser.setState(batteryLevel: batteryLevel)
        if self.userStateLabel.text != self.currentUser.state {
            self.userStateLabel.text = self.currentUser.state
//        this may be problematic at some time
//        create new UsersConnectivity which uses new user state
            self.usersConnectivity = UsersConnectivity(userModel: currentUser)
            self.usersConnectivity.delegate = self;
            self.setUIContent(userModel: self.currentUser)
        }
    }
    
    func setUIContent(userModel: UserModel) {
        self.currentUserImageView.image = UIImage(named: "ghost_avatar.png")
        self.usernameLabel.text = userModel.username
        self.userStateLabel.text = userModel.state
    }
    
    @objc func signOutButtonTap() {
        UserDefaults.standard.set(false, forKey: Constants.UserDefaults.isLoged)
        UserDefaults.standard.synchronize()
        let loginVC: LoginViewController = storyboard?.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
        loginVC.loginDelegate = self
        self.present(loginVC, animated: true, completion: {
            self.usersConnectivity.didSignOut()
            let realm = try! Realm()
            try? realm.write {
                realm.delete(realm.objects(UserModel.self).filter("userID == %d", -1))
            }
        })
    }

}

extension NearbyUsersViewController: NearbyUsersDelegate {
   
    func didLostUser(peerID: MCPeerID) {
        self.users.removeValue(forKey: peerID)
        self.nearbyUsersCollectionView.reloadData()
    }
    
    func didFindNewUser(user: UserModel, peerID: MCPeerID) {
        self.users[peerID] = user
        let realm = try! Realm()
        if realm.objects(UserModel.self).filter("username == %@", user.username).first == nil {
            realm.beginWrite()
            realm.add(user)
            try! realm.commitWrite()
        }
        self.nearbyUsersCollectionView.reloadData()
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
