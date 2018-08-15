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
    
    //    MARK: Properties
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var signInLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var greyContainerView: UIView!
    
    @IBOutlet weak var backgroundView: UIView!
    //    MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let context = CIContext(options: nil)
        
        let currentFilter = CIFilter(name: "CIGaussianBlur")
        let beginImage = CIImage(image: #imageLiteral(resourceName: "login_background.jpg"))
        currentFilter!.setValue(beginImage, forKey: kCIInputImageKey)
        currentFilter!.setValue(8, forKey: kCIInputRadiusKey)
        
        let cropFilter = CIFilter(name: "CICrop")
        cropFilter!.setValue(currentFilter!.outputImage, forKey: kCIInputImageKey)
        cropFilter!.setValue(CIVector(cgRect: beginImage!.extent), forKey: "inputRectangle")
        
        let output = cropFilter!.outputImage
        let cgimg = context.createCGImage(output!, from: output!.extent)
        let processedImage = UIImage(cgImage: cgimg!)
        backgroundView.backgroundColor = UIColor(patternImage: processedImage)
        
        self.greyContainerView.backgroundColor = UIColor(displayP3Red: 0.2, green: 0.3, blue: 0.4, alpha: 0.5)
        
        self.usernameTextField.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        self.confirmPasswordTextField.attributedPlaceholder = NSAttributedString(string: "Confirm password", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
        self.confirmPasswordTextField.delegate = self
        self.signInLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.signInLabelTap)))
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.backgroundView.layer.addPulsingAnimation()
        self.backgroundView.layer.addScaleXAnimation()
        self.backgroundView.layer.addScaleYAnimation()
    }
    
    //    MARK: Button taps
    
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
    
    //    MARK: Keyboard notifications
    
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
