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
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
        self.confirmPasswordTextField.delegate = self
        self.signInLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.signInLabelTap)))
    }
    
    @objc func signInLabelTap() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func registerButtonTap(_ sender: Any) {
        let username: String! = self.usernameTextField.text
        let password: String! = self.passwordTextField.text
        let confirmPassword: String! = self.confirmPasswordTextField.text
        
        let authorization = self.authorizeUserInput(username: username, password: password, confirmedPassword: confirmPassword)
        if authorization.success {
            let realm = try! Realm()
            if realm.objects(UserModel.self).filter("username = %@", username).first == nil {
                let user: UserModel! = UserModel()
                user.username = username
                user.password = password
                user.uniqueDeviceID = (UIDevice.current.identifierForVendor?.uuidString)!
                user.userID = realm.objects(UserModel.self).count
                realm.beginWrite()
                realm.add(user)
                try! realm.commitWrite()
                self.presentingViewController?.view.makeToast("Sign up successfully", point: CGPoint(x: self.view.center.x, y: self.view.frame.size.height - 50), title: "", image: #imageLiteral(resourceName: "ghost_avatar.png"), completion: nil)
                self.dismiss(animated: true, completion: nil)
            }
            else {
                self.view.makeToast("User already exists", point: CGPoint(x: self.view.center.x, y: self.view.frame.size.height - 50), title: "", image: #imageLiteral(resourceName: "ghost_avatar.png"), completion: nil)
            }
            
        }
        else {
            self.view.makeToast(authorization.message, point: CGPoint(x: self.view.center.x, y: self.view.frame.size.height - 50), title: "", image: #imageLiteral(resourceName: "ghost_avatar.png"), completion: nil)
        }

    }
    
    func authorizeUserInput(username: String, password: String, confirmedPassword: String) -> (success: Bool, message: String) {
        let message: String
        if username.count < 4 {
            message = "Username is too short"
        }
        else if username.count > 12 {
            message = "Username is too long"
        }
        else if password.count < 5 {
            message = "Password is too short"
        }
        else if password.count > 14 {
            message = "Password is too long"
        }
        else if confirmedPassword != password {
            message = "Confirm password doesn't match"
        }
        else {
            message = ""
        }
        
        let success = message == "" ? true : false
        return (success, message)
    }
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case self.usernameTextField:
            self.passwordTextField.becomeFirstResponder()
        case self.passwordTextField:
            self.confirmPasswordTextField.becomeFirstResponder()
        case self.confirmPasswordTextField:
            self.registerButtonTap("")
        default:
            break
        }
        return true
    }
}
