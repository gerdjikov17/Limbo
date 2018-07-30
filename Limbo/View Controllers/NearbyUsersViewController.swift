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
    var pastelView: PastelView?
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addPastelViewToCollectionViewBackground()
        if let user = self.currentUser {
            self.setUIContent(userModel: user)
        }
        self.usersConnectivity.chatDelegate = self
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
        self.currentUserImageView.image = UIImage(named: self.currentUser.avatarString)
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
    
    @objc func userImageTap() {
        let avatarChooseVC = storyboard?.instantiateViewController(withIdentifier: "AvatarCollectionViewController") as! AvatarCollectionViewController
        avatarChooseVC.currentUser = self.currentUser
        self.navigationController?.present(avatarChooseVC, animated: true, completion: nil)
    }

    
    func addPastelViewToCollectionViewBackground() {
        
        if self.pastelView == nil {
            let pastelView = PastelView(frame: self.view.frame)
            pastelView.startPastelPoint = .bottomLeft
            pastelView.endPastelPoint = .topRight
            pastelView.animationDuration = 3.0
            pastelView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            pastelView.setColors([
                UIColor(red:0.31, green:0.31, blue:0.31, alpha:1.0),
                UIColor(red:0.88, green:0.88, blue:0.88, alpha:1.0),
                UIColor(red:0.45, green:0.44, blue:0.49, alpha:1.0)
                ])
            pastelView.startAnimation()
            //        self.nearbyUsersCollectionView.backgroundView = pastelView
            self.nearbyUsersCollectionView.backgroundColor = .clear
            
            
            let pastelView2 = PastelView(frame: self.view.frame)
            pastelView2.startPastelPoint = .bottomLeft
            pastelView2.endPastelPoint = .topRight
            pastelView2.animationDuration = 3.0
            pastelView2.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            pastelView2.setColors([
                UIColor(red:0.31, green:0.34, blue:0.31, alpha:1.0),
                UIColor(red:0.88, green:0.85, blue:0.88, alpha:1.0),
                UIColor(red:0.45, green:0.41, blue:0.49, alpha:1.0)
                ])
            pastelView2.startAnimation()
            
            self.view.addSubview(pastelView2)
            self.view.sendSubview(toBack: pastelView2)
            self.view.insertSubview(pastelView, aboveSubview: pastelView2)
            
            self.pastelView = pastelView
        }
        else {
            pastelView?.startAnimation()
        }
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

extension NearbyUsersViewController: ChatDelegate {
    func didReceiveMessage(threadSafeMessageRef: ThreadSafeReference<MessageModel>, fromPeerID: MCPeerID) {
        //        create a notificiation that message is received
        DispatchQueue.main.async {
            let realm = try! Realm()
            let messageModel = realm.resolve(threadSafeMessageRef)
            let userChattingWith = messageModel?.sender
            let notificationManager = LNRNotificationManager()
            notificationManager.notificationsPosition = .top
            notificationManager.notificationsBackgroundColor = .white
            notificationManager.notificationsTitleTextColor = .black
            notificationManager.notificationsBodyTextColor = .darkGray
            notificationManager.notificationsSeperatorColor = .gray
            
            notificationManager.showNotification(notification: LNRNotification(title: (userChattingWith?.username)!, body:messageModel?.messageString , duration: 3, onTap: {
                
                let chatVC: ChatViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chatVC") as! ChatViewController
                self.usersConnectivity.inviteUser(peerID: fromPeerID)
                chatVC.currentUser = self.currentUser
                chatVC.userChattingWith = userChattingWith
                chatVC.peerIDChattingWith = fromPeerID
                chatVC.chatDelegate = self.usersConnectivity
                self.usersConnectivity.chatDelegate = chatVC
                self.navigationController?.pushViewController(chatVC, animated: true)
                
            }, onTimeout: {
                
            }))
        }
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
