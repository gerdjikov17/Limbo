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
import QuartzCore

class LoginViewController: UIViewController {
    
    //    MARK: Properties
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var greyContainerView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    
    var loginDelegate: LoginDelegate?
    
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
        
        self.usernameTextField.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        
        self.greyContainerView.backgroundColor = UIColor(displayP3Red: 0.2, green: 0.3, blue: 0.4, alpha: 0.5)
        
        
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
        self.signUpLabel?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LoginViewController.signUpLabelTap)))
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
    
    @objc func signUpLabelTap() {
        let registerVC = (storyboard?.instantiateViewController(withIdentifier: "registerVC"))
        registerVC?.modalTransitionStyle = .crossDissolve
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
    
    private func authorizeUserInput(usernameString: String, passwordString: String) -> (success: Bool, message: String) {
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
    
    //    MARK: Keyboard Notifications
    
    @objc private func keyboardWillShow(notification:NSNotification){
        
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }
    
    @objc private func keyboardWillHide(notification:NSNotification){
        
        let contentInset:UIEdgeInsets = .zero
        scrollView.contentInset = contentInset
    }
    
}

//MARK: Protocol conforms

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
