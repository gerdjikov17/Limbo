//
//  OptionsViewController.swift
//  Limbo
//
//  Created by A-Team User on 20.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit

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
}
