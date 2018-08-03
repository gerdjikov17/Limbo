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
import Pastel

class NearbyUsersViewController: UIViewController {

    var currentUser: UserModel! {
        return RealmManager.currentLoggedUser()
    }
    var users: [MCPeerID: UserModel]!
    var usersConnectivity: UsersConnectivity!
    var itemsCountIfBlind = 0
    @IBOutlet weak var nearbyUsersCollectionView: UICollectionView!
    @IBOutlet weak var currentUserImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userStateLabel: UILabel!
    @IBOutlet weak var candleCountLabel: UILabel!
    @IBOutlet weak var medallionCountLabel: UILabel!
    @IBOutlet weak var candleImageView: UIImageView!
    @IBOutlet weak var medallionImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.users = Dictionary()
        let spectreManager = SpectreManager(nearbyUsersDelegate: self)
        spectreManager.startLoopingForSpectres()

        navigationController?.navigationBar.barTintColor = UIColor(red:0.02, green:0.11, blue:0.16, alpha:0.5)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign out", style: .plain, target: self, action: #selector(self.signOutButtonTap))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Reload", style: .plain, target: self, action: #selector(self.reloadDataFromSelector))
        self.currentUserImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.userImageTap)))
        self.candleImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.candleImageTap)))
        self.medallionImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.medallionImageTap)))
        
        self.nearbyUsersCollectionView.emptyDataSetSource = self;
        self.nearbyUsersCollectionView.emptyDataSetDelegate = self;
        
        if !UserDefaults.standard.bool(forKey: Constants.UserDefaults.isLoged) {
            let loginVC: LoginViewController = storyboard?.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
            loginVC.loginDelegate = self
            self.present(loginVC, animated: true, completion: nil)
        }
        else {
            self.checkForCurses(forUser: self.currentUser)
            self.currentUser.setState(batteryLevel: UIDevice.current.batteryLevel)
            self.usersConnectivity = UsersConnectivity(userModel: self.currentUser, delegate: self)
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
        if let lastCurseCastDate = forUser.curseCastDate {
            if lastCurseCastDate.timeIntervalSinceNow.isLess(than: Constants.Curses.curseTime) {
                CurseManager.removeCurse()
            }
            else {
                CurseManager.reApplyCurse(curse: Curse(rawValue: forUser.curse)!, toUser: forUser, remainingTime: lastCurseCastDate.timeIntervalSinceNow)
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
            self.usersConnectivity = UsersConnectivity(userModel: self.currentUser, delegate: self)
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
        self.candleCountLabel.text = String(userModel.items[SpecialItem.HolyCandle.rawValue]!)
        self.medallionCountLabel.text = String(userModel.items[SpecialItem.SaintsMedallion.rawValue]!)
        self.usernameLabel.text = userModel.username
        self.userStateLabel.text = userModel.state
    }
    
    @objc func signOutButtonTap() {
        if self.currentUser.curse == Curse.None.rawValue {
            UserDefaults.standard.set(false, forKey: Constants.UserDefaults.isLoged)
            UserDefaults.standard.synchronize()
            let loginVC: LoginViewController = storyboard?.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
            loginVC.loginDelegate = self
            self.present(loginVC, animated: true, completion: {
                self.usersConnectivity.didSignOut()
            })
        }
        else {
            self.view.makeToast("You can't sign out while cursed")
        }
        
//        self.batteryLevelDidChange(notification: NSNotification.init(name: NSNotification.Name.UIDeviceBatteryLevelDidChange, object: nil, userInfo: nil))
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
        
        if peerID.displayName == "Spectre" {
            itemsCountIfBlind = 0
        }
        
        self.nearbyUsersCollectionView.reloadData()
    }
    
    func didFindNewUser(user: UserModel, peerID: MCPeerID) {
        self.users[peerID] = user
        
        if user.state == "Spectre" {
            itemsCountIfBlind = 1
        }
        
        self.nearbyUsersCollectionView.reloadData()
    }
}

extension NearbyUsersViewController: LoginDelegate {
    func didLogin(userModel: UserModel) {
        self.currentUser.setState(batteryLevel: UIDevice.current.batteryLevel)
        self.usersConnectivity = UsersConnectivity(userModel: self.currentUser, delegate: self)
        self.setUIContent(userModel: self.currentUser)
        UserDefaults.standard.set(true, forKey: Constants.UserDefaults.isLoged)
        UserDefaults.standard.set(userModel.userID, forKey: Constants.UserDefaults.loggedUserID)
        UserDefaults.standard.synchronize()
        self.dismiss(animated: true, completion: nil)
    }
    
}
