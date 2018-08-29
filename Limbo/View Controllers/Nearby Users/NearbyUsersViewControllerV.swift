//
//  NearbyUsersViewControllerV.swift
//  Limbo
//
//  Created by A-Team User on 27.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit
import Toast_Swift
import DZNEmptyDataSet
import RealmSwift


class NearbyUsersViewControllerV: UIViewController {

    @IBOutlet weak var nearbyUsersCollectionView: UICollectionView!
    @IBOutlet weak var currentUserImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userStateLabel: UILabel!
    @IBOutlet weak var candleCountLabel: UILabel!
    @IBOutlet weak var medallionCountLabel: UILabel!
    @IBOutlet weak var candleImageView: UIImageView!
    @IBOutlet weak var medallionImageView: UIImageView!
    
    var presenter: NearbyUsersViewToPresenterInterface!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        self.nearbyUsersCollectionView.emptyDataSetSource = self
        self.nearbyUsersCollectionView.emptyDataSetDelegate = self
        self.presenter.firstInitialization()
        

        NotificationCenter.default.addObserver(self, selector: #selector(batteryLevelDidChange(notification:)), name: NSNotification.Name.UIDeviceBatteryLevelDidChange, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.presenter.viewDidAppear()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        PastelViewManager.addPastelViewToCollectionViewBackground(collectionView: self.nearbyUsersCollectionView, withSuperView: self.view)
    }
    
    @objc func signOutButtonTap() {
        self.presenter.signOutButtonTap()
        
        //        self.batteryLevelDidChange(notification: NSNotification.init(name: NSNotification.Name.UIDeviceBatteryLevelDidChange, object: nil, userInfo: nil))
    }
    
    @objc func userImageTap() {
        
        self.presenter.userImageTap()
    }
    
    @objc func becomeGhost() {
        let realm = try! Realm()
        let results = realm.objects(ChatRoomModel.self).filter("name = %@", "Unnamed group")
//        self.chatRooms.remove(at: self.chatRooms.index(where: { (key, value) -> Bool in
//            value.chatRoom.name == "Unnamed group"
//        })!)
        try! realm.write {
            realm.delete(results)
        }
        self.nearbyUsersCollectionView.reloadData()
//        var batteryLevel: Float
//        if RealmManager.currentLoggedUser()!.state == "Human" {
//            batteryLevel = 0.047
//        }
//        else if RealmManager.currentLoggedUser()!.state == "Ghost" {
//            batteryLevel = 0.26
//        }
//        else if RealmManager.currentLoggedUser()!.state == "Dying" {
//            batteryLevel = 0.51
//        }
//        else {
//            batteryLevel = 0.11
//        }
//        self.presenter.batteryLevelDidChange(batteryLevel: batteryLevel)
    }
    
    @objc func reloadDataFromSelector() {
        DispatchQueue.main.async {
            self.nearbyUsersCollectionView.reloadData()
//            self.setUIContent(userModel: self.currentUser)
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
    
    @objc func batteryLevelDidChange(notification: NSNotification) {
        self.presenter.batteryLevelDidChange(batteryLevel: UIDevice.current.batteryLevel)
    }
    
    @objc func candleImageTap() {
        self.presenter.candleImageTap(sourceView: self.currentUserImageView, presentingVC: self)
    }
    
    @objc func medallionImageTap() {
        self.presenter.medallionImageTap(sourceView: self.currentUserImageView, presentingVC: self)
    }
    
    

}

extension NearbyUsersViewControllerV: NearbyUsersPresenterToViewInterface {
    func reloadData() {
        self.nearbyUsersCollectionView.reloadData()
    }
    
    func showToast(message: String) {
        self.view.makeToast(message)
    }
    
    func showGiftToast() {
        var style = ToastStyle()
        style.backgroundColor = UIColor.white
        style.titleColor = .black
        style.messageColor = .black
        self.view.hideToast()
        self.view.makeToast("As a new user you are twice likely to find spectres.", duration: 3600 , point: CGPoint(x: self.currentUserImageView.center.x, y: self.currentUserImageView.center.y - 115), title: "The Gift", image: #imageLiteral(resourceName: "gift-icon.png"), style: style, completion: nil)
    }
}
