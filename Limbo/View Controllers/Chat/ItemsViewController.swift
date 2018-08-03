//
//  ItemsViewController.swift
//  Limbo
//
//  Created by A-Team User on 1.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit
import UserNotifications

class ItemsViewController: UIViewController {

    var user: UserModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func holyCandleButtonTap(_ sender: Any) {
        if user.curse != Curse.None.rawValue {
            NotificationManager.shared.presentItemNotification(withTitle: "Holy Candle", andText: "You removed your curse using holy candle")
            CurseManager.removeCurse()
        }
        else {
            NotificationManager.shared.presentItemNotification(withTitle: "Holy Candle", andText: "You are not cursed")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saintsMedallionButtonTap(_ sender: Any) {
        CurseManager.applySpecialItem(specialItem: SpecialItem.SaintsMedallion, toUser: self.user)

        self.dismiss(animated: true, completion: nil)
    }
}
