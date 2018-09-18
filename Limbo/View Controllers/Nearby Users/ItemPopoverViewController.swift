//
//  ItemPopoverViewController.swift
//  Limbo
//
//  Created by A-Team User on 3.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit
import RealmSwift

class ItemPopoverViewController: UIViewController {
    
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemCountLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    
    var specialItem: SpecialItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard RealmManager.currentLoggedUser() != nil else { return }
        guard let specialItem = specialItem else { return }
        
        switch specialItem.rawValue {
        case SpecialItem.HolyCandle.rawValue :
            itemNameLabel.text = "Holy Candle"
        case SpecialItem.SaintsMedallion.rawValue :
            itemNameLabel.text = "Saint's Medallion"
        default:
            itemNameLabel.text = "Exodia"
        }
        itemCountLabel.text = String(0)
        stepper.value = Double(0)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func useItemButtonTap(_ sender: Any) {
        if let user = RealmManager.currentLoggedUser() {
            CurseManager.applySpecialItem(specialItem: self.specialItem!, toUser: user)
        }
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func stepperValueChanged(_ sender: Any) {
        itemCountLabel.text = String(Int(stepper.value))
    }
    
    @IBAction func buyItemsButtonTap(_ sender: Any) {
        let realm = try! Realm()
        realm.beginWrite()
        RealmManager.currentLoggedUser()?.items[specialItem!.rawValue]! += Int(stepper.value)
        try? realm.commitWrite()
        realm.refresh()
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
