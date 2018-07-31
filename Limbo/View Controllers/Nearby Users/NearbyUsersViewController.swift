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
import LNRSimpleNotifications
import Pastel

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
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Reload", style: .plain, target: self, action: #selector(self.reloadDataFromSelector))
        self.currentUserImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.userImageTap)))
        
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
            self.checkForCurses(forUser: self.currentUser)
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.nearbyUsersCollectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let user = self.currentUser {
            self.setUIContent(userModel: user)
            self.usersConnectivity.chatDelegate = self
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addPastelViewToCollectionViewBackground()
    }
    
    func checkForCurses(forUser: UserModel) {
        if let lastCurse = UserDefaults.standard.string(forKey: Constants.UserDefaults.lastCurse) {
            if lastCurse != "" {
                let lastCurse = Curse(rawValue: lastCurse)
                let lastCurseDate = UserDefaults.standard.object(forKey: Constants.UserDefaults.lastCurseDate) as! Date
                let timeInterval = Date.timeIntervalSince(Date())
                let remainingTime = Constants.Curses.curseTime - timeInterval(lastCurseDate)
                if remainingTime > 0 {
                    CurseManager.reApplyCurse(curse: lastCurse!, toUser: forUser, remainingTime: remainingTime)
                    self.didReceiveCurse(curse: lastCurse!, remainingTime: remainingTime)
                }
            }
        }
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
        if let defaultImage = UIImage(named: userModel.avatarString) {
            self.currentUserImageView.image = defaultImage
        }
        else {
            let imgurImage = try! UIImage(data: Data(contentsOf: URL(string: userModel.avatarString)!))
            self.currentUserImageView.image = imgurImage
        }
        self.usernameLabel.text = userModel.username
        self.userStateLabel.text = userModel.state
    }
    
    @objc func signOutButtonTap() {
        if self.currentUser.curse == .None {
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
        else {
            self.view.makeToast("You can't sign out while cursed")
        }
        
    }
    
    @objc func userImageTap() {
        let avatarChooseVC = storyboard?.instantiateViewController(withIdentifier: "AvatarCollectionViewController") as! AvatarCollectionViewController
        avatarChooseVC.currentUser = self.currentUser
        self.navigationController?.present(avatarChooseVC, animated: true, completion: nil)
    }

    
    func addPastelViewToCollectionViewBackground() {
        
        let pastelView = PastelView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.nearbyUsersCollectionView.frame.height))
        pastelView.startPastelPoint = .bottomLeft
        pastelView.endPastelPoint = .topRight
        pastelView.animationDuration = 3.0
        pastelView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pastelView.setColors([
            UIColor(red:0.46, green:0.43, blue:0.60, alpha:1.0),
            UIColor(red:0.37, green:0.33, blue:0.55, alpha:1.0),
            UIColor(red:0.23, green:0.20, blue:0.36, alpha:1.0)
            ])
        
        self.nearbyUsersCollectionView.backgroundView = pastelView
        self.nearbyUsersCollectionView.backgroundColor = .clear
        
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.nearbyUsersCollectionView.frame.height)
        let endColor = UIColor(red:0.02, green:0.11, blue:0.16, alpha:0.5)
        gradient.colors = [UIColor.clear.cgColor, endColor.cgColor, endColor.cgColor, UIColor.clear.cgColor]
        gradient.locations = [0, 0.1, 0.9, 1]
        pastelView.layer.mask = gradient
        
        pastelView.startAnimation()
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
    
    func isPeerAGhost(peerID: MCPeerID) -> Bool {
        return self.users[peerID]?.state == "Ghost"
    }
}

extension NearbyUsersViewController: LoginDelegate {
    func didLogin(userModel: UserModel) {
        self.currentUser = userModel
        self.currentUser.setState(batteryLevel: UIDevice.current.batteryLevel)
        self.usersConnectivity = UsersConnectivity(userModel: currentUser)
        self.usersConnectivity.delegate = self;
        self.setUIContent(userModel: self.currentUser)
        UserDefaults.standard.set(true, forKey: Constants.UserDefaults.isLoged)
        UserDefaults.standard.set(userModel.userID, forKey: Constants.UserDefaults.loggedUserID)
        UserDefaults.standard.synchronize()
        self.dismiss(animated: true, completion: nil)
    }
    
}
