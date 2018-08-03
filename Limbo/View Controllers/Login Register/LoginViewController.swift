//
//  LoginViewController.swift
//  Limbo
//
//  Created by A-Team User on 24.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import Foundation
import UIKit
import Toast_Swift

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var loginDelegate: LoginDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
        self.signUpLabel?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LoginViewController.signUpLabelTap)))
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func signUpLabelTap() {
        let registerVC = (storyboard?.instantiateViewController(withIdentifier: "registerVC"))
        self.present(registerVC!, animated: true, completion: nil)
    }
    
    @IBAction func loginButtonTap(_ sender: Any) {
        self.resignAllTextFields()
        let usernameString: String! = self.usernameTextField?.text
        let passwordString: String! = self.passwordTextField?.text
        let authorization = self.authorizeUserInput(usernameString: usernameString, passwordString: passwordString)
        if authorization.success {
            if let user = RealmManager.userWith(username: usernameString, password: passwordString){
                self.loginDelegate?.didLogin(userModel: user)
            }
            else {
                self.view.makeToast("User doesn't exist", point: CGPoint(x: self.view.center.x, y: 100), title: "", image: #imageLiteral(resourceName: "ghost_avatar.png"), completion: nil)
            }
        }
        else {
            self.view.makeToast(authorization.message, point: CGPoint(x: self.view.center.x, y: 100), title: "", image: #imageLiteral(resourceName: "ghost_avatar.png"), completion: nil)
        }
    }
    
    func authorizeUserInput(usernameString: String, passwordString: String) -> (success: Bool, message: String) {
        let message: String
        
        if usernameString.count < 4 {
            message = "Username is too short"
        }
        else if usernameString.count > 12 {
            message = "Username is too long"
        }
        else if passwordString.count < 5 {
            message = "Password is too short"
        }
        else if passwordString.count > 14 {
            message = "Password is too long"
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

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.usernameTextField {
            self.passwordTextField.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
            self.loginButtonTap("")
        }
        
        return true
    }
    
    func resignAllTextFields() {
        self.usernameTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
    }
}
