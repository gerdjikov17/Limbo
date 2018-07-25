//
//  LoginViewController.swift
//  Limbo
//
//  Created by A-Team User on 24.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpLabel: UILabel!
    
    var loginDelegate: LoginDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.signUpLabel?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LoginViewController.signUpLabelTap)))
    }
    
    @objc func signUpLabelTap() {
        let registerVC = (storyboard?.instantiateViewController(withIdentifier: "registerVC"))
        self.present(registerVC!, animated: true, completion: nil)
    }
    
    @IBAction func loginButtonTap(_ sender: Any) {
        if (((self.usernameTextField?.text!.count)! > 3) && ((self.passwordTextField?.text!.count)! > 3)) {
            let realm = try! Realm()
            let usernameString: String! = self.usernameTextField?.text
            let passwordString: String! = self.passwordTextField?.text
            if let user = (realm.objects(UserModel.self).filter("username = %@ and password = %@", usernameString, passwordString)).first {
                self.loginDelegate?.didLogin(userModel: user)
            }

        }
        
    }
}
