//
//  OptionsViewController.swift
//  Limbo
//
//  Created by A-Team User on 20.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit
import Toast_Swift

class OptionsViewController: UIViewController {

    var optionsDelegate: OptionsDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func clearHistoryButtonTap(_ sender: Any) {
        self.dismiss(animated: true) {
            self.optionsDelegate.clearHistory()
        }
    }
    
     @IBAction func showImagesButtonTap(_ sender: Any) {
        self.dismiss(animated: true) {
            self.optionsDelegate.showImages()
        }
     }
    
    @IBAction func changeChatNameButtonTap(_ sender: Any) {
        let alertController = UIAlertController(title: "Change name", message: "Change group chat name\nChanges will be visible only from you", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: nil)
        alertController.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action) in
            guard let newName = alertController.textFields?.first?.text else {
                return
            }
            if newName.count > 2 {
                self.optionsDelegate.changeGroupChatName(newName: newName)
            }
            else {
                UIApplication.shared.keyWindow?.makeToast("New name must be longer than 2 characters")
            }
            
        }))
        alertController.addAction(UIAlertAction(title: "Abort", style: .cancel, handler: { (action) in
            
        }))
        let presentingVC = self.presentingViewController!
        self.presentingViewController?.dismiss(animated: true, completion: {
            presentingVC.present(alertController, animated: true, completion: nil)
        })
        
    }
    
    @IBAction func usersButtonTap(_ sender: Any) {
        let allUsersTVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "allUsersTVC") as! AllUsersTableViewController
        allUsersTVC.users = self.optionsDelegate.usersInCurrentRoom()
        self.presentingViewController?.dismiss(animated: true, completion: {
            self.optionsDelegate.pushVC(vc: allUsersTVC)
        })
    }
    
}
