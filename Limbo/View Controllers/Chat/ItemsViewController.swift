//
//  ItemsViewController.swift
//  Limbo
//
//  Created by A-Team User on 1.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit
import LNRSimpleNotifications

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
        let notificationManager = LNRNotificationManager()
        notificationManager.notificationsPosition = .top
        notificationManager.notificationsBackgroundColor = .white
        notificationManager.notificationsTitleTextColor = .black
        notificationManager.notificationsBodyTextColor = .darkGray
        notificationManager.notificationsSeperatorColor = .gray
        if user.curse != .None {
            notificationManager.showNotification(notification: LNRNotification(title: "Holy Candle", body: "You removed your curse using holy candle"))
            user.curse = .None
        }
        else {
            notificationManager.showNotification(notification: LNRNotification(title: "Holy Candle", body: "You are not cursed"))
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saintsMedallionButtonTap(_ sender: Any) {
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
