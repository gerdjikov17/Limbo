//
//  RegisterViewController.swift
//  Limbo
//
//  Created by A-Team User on 24.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var signInLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func registerButtonTap(_ sender: Any) {
        let username: String! = self.usernameTextField.text
        let password: String! = self.passwordTextField.text
        let confirmPassword: String! = self.confirmPasswordTextField.text
        
        if (username.count > 3 && username.count < 10) {
            if password.count > 4 {
                if password == confirmPassword {
                    let realm = try! Realm()
                    let user: UserModel! = UserModel()
                    user.username = username
                    user.password = password
                    realm.beginWrite()
                    realm.add(user)
                    try! realm.commitWrite()
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}
