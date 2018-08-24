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
import Toast_Swift
import RealmSwift
import Pastel

class NearbyUsersViewController: UIViewController {

    //    MARK: Properties
    
    var currentUser: UserModel! {
        return RealmManager.currentLoggedUser()
    }
    var notificationToken: NotificationToken?
    var chatRooms: [MCPeerID: (chatRoom: ChatRoomModel, unreadMessages: Int)]!
    var lastSelectedChatRoomUUID: String?
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
    
    //    MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.chatRooms = Dictionary()
        let spectreManager = SpectreManager(nearbyUsersDelegate: self)
        spectreManager.startLoopingForSpectres()

        navigationController?.navigationBar.barTintColor = UIColor(red:0.02, green:0.11, blue:0.16, alpha:0.5)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        let rightButtonItemSignOut = UIBarButtonItem(title: "Sign out", style: .plain, target: self, action: #selector(self.signOutButtonTap))
        let rightButtonItemChangeState = UIBarButtonItem(title: "Ghost", style: .plain, target: self, action: #selector(self.becomeGhost))
        navigationItem.rightBarButtonItems = [rightButtonItemSignOut, rightButtonItemChangeState]
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Reload", style: .plain, target: self, action: #selector(self.reloadDataFromSelector))
        self.currentUserImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.userImageTap)))
        self.candleImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.candleImageTap)))
        self.candleImageView.layer.cornerRadius = 10
        self.medallionImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.medallionImageTap)))
        self.medallionImageView.layer.cornerRadius = 10
        
        self.nearbyUsersCollectionView.emptyDataSetSource = self;
        self.nearbyUsersCollectionView.emptyDataSetDelegate = self;
        
        if !UserDefaults.standard.bool(forKey: Constants.UserDefaults.isLoged) {
            let loginVC: LoginViewController = storyboard?.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
            loginVC.loginDelegate = self
            self.present(loginVC, animated: true, completion: nil)
        }
        else {
            self.initRequiredPropertiesForLoggedUser()
            
        }
        NotificationCenter.default.addObserver(self, selector: #selector(batteryLevelDidChange(notification:)), name: NSNotification.Name.UIDeviceBatteryLevelDidChange, object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.lastSelectedChatRoomUUID = nil
        self.addGroupChatCell()
        self.nearbyUsersCollectionView.reloadData()
        self.checkForGifts()
        self.showGroupChats()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (UserDefaults.standard.bool(forKey: Constants.UserDefaults.isLoged) && (self.currentUser) != nil) {
            self.usersConnectivity.chatDelegate = self
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        PastelViewManager.addPastelViewToCollectionViewBackground(collectionView: self.nearbyUsersCollectionView, withSuperView: self.view)
    }
    
    //    MARK: Business Logic
    
    private func checkForCurses(forUser: UserModel) {
        if let lastCurseCastDate = forUser.curseCastDate {
            if lastCurseCastDate.timeIntervalSinceNow.isLess(than: Constants.Curses.curseTime) {
                CurseManager.removeCurse()
            }
            else {
                CurseManager.reApplyCurse(curse: Curse(rawValue: forUser.curse)!, toUser: forUser, remainingTime: lastCurseCastDate.timeIntervalSinceNow)
            }
        }
    }
    
    private func checkForGifts() {
        if let gift = UserDefaults.standard.value(forKey: Constants.UserDefaults.gift) {
            let gift = gift as! [String: Any]
            if gift["username"] as? String == RealmManager.currentLoggedUser()?.username {
                let date = gift["date"] as! Date
                let oneDayTimeInterval = -86400.0
                if date.timeIntervalSinceNow > oneDayTimeInterval {
                    var style = ToastStyle()
                    style.backgroundColor = UIColor.white
                    style.titleColor = .black
                    style.messageColor = .black
                    self.view.hideToast()
                    self.view.makeToast("As a new user you are twice likely to find spectres.", duration: 3600 , point: CGPoint(x: self.currentUserImageView.center.x, y: self.currentUserImageView.center.y - 115), title: "The Gift", image: #imageLiteral(resourceName: "gift-icon.png"), style: style, completion: nil)
                }
            }
        }
    }
    
    private func setUIContent(userModel: UserModel) {
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
    
    private func initRequiredPropertiesForLoggedUser() {
        self.checkForCurses(forUser: self.currentUser)
        self.currentUser.setState(batteryLevel: UIDevice.current.batteryLevel)
        self.usersConnectivity = UsersConnectivity(userModel: self.currentUser, delegate: self, peerID: nil)
        self.setUIContent(userModel: self.currentUser)
        self.notificationToken = self.currentUser.observe { (objectChange) in
            self.setUIContent(userModel: self.currentUser)
            self.filterUsersToShow()
        }
    }
    
    @objc func batteryLevelDidChange(notification: NSNotification) {
        let batteryLevel = UIDevice.current.batteryLevel
        self.currentUser.setState(batteryLevel: batteryLevel)
        if self.userStateLabel.text != self.currentUser.state {
            self.userStateLabel.text = self.currentUser.state
        }
    }
    
    @objc func reloadDataFromSelector() {
        DispatchQueue.main.async {
            self.nearbyUsersCollectionView.reloadData()
            self.setUIContent(userModel: self.currentUser)
        }
    }
    
    @objc func becomeGhost() {
        let realm = try! Realm()
        let results = realm.objects(ChatRoomModel.self).filter("name = %@", "Unnamed group")
        self.chatRooms.remove(at: self.chatRooms.index(where: { (key, value) -> Bool in
            value.chatRoom.name == "Unnamed group"
        })!)
        try! realm.write {
            realm.delete(results)
        }
        self.nearbyUsersCollectionView.reloadData()
//        var batteryLevel: Float
//        if self.currentUser.state == "Human" {
//            batteryLevel = 0.047
//        }
//        else if self.currentUser.state == "Ghost" {
//            batteryLevel = 0.26
//        }
//        else if self.currentUser.state == "Dying" {
//            batteryLevel = 0.51
//        }
//        else {
//            batteryLevel = 0.11
//        }
//        self.currentUser.setState(batteryLevel: batteryLevel)
//        if self.userStateLabel.text != self.currentUser.state {
//            self.userStateLabel.text = self.currentUser.state
//        }
    }
    
    private func filterUsersToShow() {
        var newUsers: [MCPeerID: (chatRoom: ChatRoomModel, unreadMessages: Int)] = Dictionary()
//        error here
        guard let chatRooms = self.chatRooms else {
            self.chatRooms = newUsers
            return
        }
        for key in chatRooms.keys {
            let value = chatRooms[key]
            if (value?.chatRoom.usersChattingWith.count)! > 1 {
                newUsers[key] = self.chatRooms[key]
            }
            else {
                if key.displayName == "C" || self.usersConnectivity.shouldShowUserDependingOnState(currentUserState: self.currentUser.state, foundUserState: (chatRooms[key]?.chatRoom.usersChattingWith.first!.state)!) {
                    newUsers[key] = chatRooms[key]
                }
            }
        }
        self.chatRooms = newUsers
        self.reloadDataFromSelector()
    }
    
    //MARK: Button taps
    
    @objc func signOutButtonTap() {
        guard self.currentUser.curse == Curse.None.rawValue else {
            self.view.makeToast("You can't sign out while cursed")
            return
        }
        RealmManager.clearUsersStates()
        UserDefaults.standard.set(false, forKey: Constants.UserDefaults.isLoged)
        UserDefaults.standard.synchronize()
        let loginVC: LoginViewController = storyboard?.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
        loginVC.loginDelegate = self
        loginVC.modalTransitionStyle = .crossDissolve
        self.present(loginVC, animated: true, completion: {
            self.usersConnectivity.didSignOut()
        })
        
//        self.batteryLevelDidChange(notification: NSNotification.init(name: NSNotification.Name.UIDeviceBatteryLevelDidChange, object: nil, userInfo: nil))
    }
    
    @objc func userImageTap() {
        let avatarChooseVC = storyboard?.instantiateViewController(withIdentifier: "AvatarCollectionViewController") as! AvatarCollectionViewController
        avatarChooseVC.currentUser = self.currentUser
        self.navigationController?.present(avatarChooseVC, animated: true, completion: nil)
    }

}

//MAKR: Protocol Conforms

extension NearbyUsersViewController: NearbyUsersDelegate {
   
    func didLostUser(peerID: MCPeerID) {
        self.chatRooms.removeValue(forKey: peerID)
        
        if peerID.displayName == "Spectre" {
            itemsCountIfBlind = 0
        }
        
        self.nearbyUsersCollectionView.reloadData()
    }
    
    func didFindNewUser(user: UserModel, peerID: MCPeerID) {
        
        let realm = try! Realm()
        if let realmChatRoom = realm.objects(ChatRoomModel.self).filter("uuid = %@", user.compoundKey).first {
            self.chatRooms[peerID] = (realmChatRoom, 0)
        }
        
        if user.state == "Spectre" {
            itemsCountIfBlind = 1
        }
        
        self.nearbyUsersCollectionView.reloadData()
    }
}

extension NearbyUsersViewController: LoginDelegate {
    func didLogin(userModel: UserModel) {
        UserDefaults.standard.set(true, forKey: Constants.UserDefaults.isLoged)
        UserDefaults.standard.set(userModel.userID, forKey: Constants.UserDefaults.loggedUserID)
        UserDefaults.standard.synchronize()
        self.initRequiredPropertiesForLoggedUser()
        self.dismiss(animated: true, completion: nil)
    }
    
}
