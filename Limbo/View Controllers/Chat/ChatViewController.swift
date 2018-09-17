//
//  ChatViewController.swift
//  Limbo
//
//  Created by A-Team User on 25.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import Foundation
import UIKit
import MultipeerConnectivity
import RealmSwift

class ChatViewController: UIViewController {

    
    //    MARK: Properties
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextFieldBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var addPhotoButton: UIButton!
    
    var chatPresenter: ChatViewToPresenterInterface!
    
    //    MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.chatTableView.dataSource = self.chatPresenter as? UITableViewDataSource
        self.chatTableView.delegate = self.chatPresenter as? UITableViewDelegate
        self.messageTextField.delegate = self;
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Options", style: .plain, target: self, action: #selector(self.optionsButtonTap))
        
        self.chatPresenter.requestMessages()
        self.chatPresenter.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.chatPresenter.viewDidAppear()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.chatPresenter.viewDidDisappear()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.chatPresenter.viewWillTransition(toSize: size)
    }
    
    
    
    //    MARK: Keyboard Notifications
    
    @objc func keyboardWillShow(notification: Notification) {
        let info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardHeight: CGFloat = keyboardSize.height
        let duration = info[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            if (self.messageTextFieldBottomConstraint.constant < 50) {
                self.messageTextFieldBottomConstraint.constant += keyboardHeight
                
            }
        }, completion: { (finished: Bool) in
            if self.messageTextFieldBottomConstraint.constant > 50 {
                self.chatPresenter.makeTableViewScrollToLastRow(animated: true)
            }
        })
        
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        let info = notification.userInfo!
        let duration = info[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.messageTextFieldBottomConstraint.constant = 5
        }, completion: { (finished: Bool) in
//            the next line reloads the data to resize the tableview and the cells
//            for unknown reason scrollToRow or setContentOffset doesn't work accordingly
            self.chatTableView.reloadData()
//            maybe this needs optimizing for better performance
        })
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    //    MARK: Button taps
    
    @objc func optionsButtonTap() {
        self.chatPresenter.didTapOnOptionsButton(navigatoinButton: self.navigationItem.rightBarButtonItem!)
        
    }
    
    @IBAction func sendButtonTap() {
        self.chatPresenter.sendButtonTap(message: self.messageTextField.text!)
        self.messageTextField.text = ""
    }
    
    @IBAction func voiceRecordButtonTap(_ sender: Any) {
        self.chatPresenter.voiceRecordButtonTap()
    }
    
    
    @IBAction func addPhotoButtonTap(_ sender: AnyObject) {
        self.chatPresenter.didTapOnAddPhotoButton(sourceView: sender as! UIView)
    }
    
    @IBAction func itemsButtonTap(_ sender: AnyObject) {
        let button: UIButton = sender as! UIButton
        //        using this hack because otherwise button.frame.origin.y is < 0 and popover is not visible
        button.frame = CGRect(x: button.frame.origin.x,
                              y: self.sendButton.frame.origin.y,
                              width: self.sendButton.frame.size.width,
                              height: self.sendButton.frame.size.height)
        
        self.chatPresenter.didTapOnItemsButton(sourceView: button)
    }
    
    @objc func didTapOnMessage(recognizer: UITapGestureRecognizer) {
        self.chatPresenter.didTapOnMessage(recognizer: recognizer, inTableView: self.chatTableView)
    }
    
    @objc func didTapOnImage(recognizer: UITapGestureRecognizer) {
        self.chatPresenter.didTapOnImage(recognizer: recognizer, inTableView: self.chatTableView)
    }
    
}
//    MARK: Protocol Conforms

//    MARK: ChatView Interface

extension ChatViewController: ChatViewInterface {
    func showSilencedMessage() {
        let pointForToast = CGPoint(x: self.view.center.x,
                                    y: (self.navigationController?.navigationBar.frame.size.height)! + CGFloat(100))
        
        let remainingTime = Constants.Curses.curseTime + (RealmManager.currentLoggedUser()?.curseCastDate?.timeIntervalSinceNow)!
        
        let curseRemainingTime = Int(remainingTime)
        
        self.view.makeToast("You are cursed with Silence",
                            point: pointForToast, title: "You can't chat with people for \(curseRemainingTime) seconds",
                            image: #imageLiteral(resourceName: "ghost_avatar.png"), completion: nil)
    }
    
    func setNavigationItemName(name: String) {
        self.navigationItem.title = name
    }
    
    func reloadAllData() {
        DispatchQueue.main.async {
            self.chatTableView.reloadData()
        }
    }
    
    func insert(indexPaths: [IndexPath]) {
        DispatchQueue.main.async {
            self.chatTableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    func scrollTo(indexPath: IndexPath, at: UITableViewScrollPosition, animated: Bool) {
        DispatchQueue.main.async {
            self.chatTableView.scrollToRow(at: indexPath, at: at, animated: animated)
        }
    }
}


//    MARK: UITextFieldDelegate

extension ChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.sendButtonTap()
        return true
    }
}



