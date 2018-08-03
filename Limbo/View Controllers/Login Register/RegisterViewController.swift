//
//  RegisterViewController.swift
//  Limbo
//
//  Created by A-Team User on 24.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import Foundation
import UIKit

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var signInLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
        self.confirmPasswordTextField.delegate = self
        self.signInLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.signInLabelTap)))
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func signInLabelTap() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func registerButtonTap(_ sender: Any) {
        self.resignAllTextFields()
        let username: String! = self.usernameTextField.text
        let password: String! = self.passwordTextField.text
        let confirmPassword: String! = self.confirmPasswordTextField.text
        
        let authorization = self.authorizeUserInput(username: username, password: password, confirmedPassword: confirmPassword)
        if authorization.success {
            if RealmManager.registerUser(username: username, password: password) {
                self.presentingViewController?.view.makeToast("Sign up successfully", point: CGPoint(x: self.view.center.x, y: 100), title: "", image: #imageLiteral(resourceName: "ghost_avatar.png"), completion: nil)
                self.dismiss(animated: true, completion: nil)
            }
            else {
                self.view.makeToast("User already exists", point: CGPoint(x: self.view.center.x, y: 100), title: "", image: #imageLiteral(resourceName: "ghost_avatar.png"), completion: nil)
            }
            
        }
        else {
            self.view.makeToast(authorization.message, point: CGPoint(x: self.view.center.x, y: 100), title: "", image: #imageLiteral(resourceName: "ghost_avatar.png"), completion: nil)
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
    
    @objc func keyboardWillShow(notification:NSNotification){
        
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        
        let contentInset:UIEdgeInsets = .zero
        scrollView.contentInset = contentInset
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
    
    func resignAllTextFields() {
        self.usernameTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        self.confirmPasswordTextField.resignFirstResponder()
    }
}
