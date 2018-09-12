//
//  ChatImageViewController.swift
//  Limbo
//
//  Created by A-Team User on 20.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit
import RealmSwift

class ChatImageViewController: UIViewController {

    @IBOutlet weak var labelBackgroundView: UIView!
    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    var panGestureRecognizer: UIPanGestureRecognizer?
    var originalPosition: CGPoint?
    var currentPositionTouched: CGPoint?
    
    var photoMessages: Results<MessageModel>!
    var currentPhotoIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(white: 1, alpha: 0.3)
        
        setUIContent(forPhotoIndex: currentPhotoIndex)
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        view.addGestureRecognizer(panGestureRecognizer!)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction)))
        
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft))
        swipeLeftGesture.direction = .left
        view.addGestureRecognizer(swipeLeftGesture)
        
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight))
        swipeRightGesture.direction = .right
        view.addGestureRecognizer(swipeRightGesture)
        
        self.scrollView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func setUIContent(forPhotoIndex: Int) {
        self.imageView.loadAsyncImage(localURL: localURL(forPhotoIndex: currentPhotoIndex))
        self.senderLabel.text = senderUsername(forPhotoIndex: currentPhotoIndex)
    }

    func localURL(forPhotoIndex: Int) -> URL {
        return FileManager.getDocumentsDirectory()
            .appendingPathComponent("Limbo")
            .appendingPathComponent(photoMessages[forPhotoIndex].messageString)
    }
    
    func senderUsername(forPhotoIndex: Int) -> String {
        return photoMessages[forPhotoIndex].sender!.username
    }
    
    func swipePhoto(left: Bool) {
        if !left {
            guard currentPhotoIndex - 1 >= 0 else { return }
            currentPhotoIndex = currentPhotoIndex - 1
        } else {
            guard currentPhotoIndex + 1 < photoMessages.count else { return }
            currentPhotoIndex = currentPhotoIndex + 1
        }
        setUIContent(forPhotoIndex: currentPhotoIndex)
    }
    
    @objc func panGestureAction(_ panGesture: UIPanGestureRecognizer) {
        let translation = panGesture.translation(in: view)
        
        if panGesture.state == .began {
            self.view.backgroundColor = UIColor(white: 1, alpha: 0.3)
            originalPosition = imageView.center
            currentPositionTouched = panGesture.location(in: view)
        } else if panGesture.state == .changed {
            imageView.frame.origin = CGPoint(x: self.view.frame.origin.x, y: translation.y)
        } else if panGesture.state == .ended {
            let velocity = panGesture.velocity(in: view)
            
            if velocity.y >= 1500 {
                UIView.animate(withDuration: 0.2
                    , animations: {
                        self.imageView.frame.origin = CGPoint(
                            x: self.view.frame.origin.x,
                            y: self.view.frame.size.height
                        )
                }, completion: { (isCompleted) in
                    if isCompleted {
                        self.dismiss(animated: false, completion: nil)
                    }
                })
            }
            else if velocity.y <= -1500 {
                UIView.animate(withDuration: 0.2
                    , animations: {
                        self.imageView.frame.origin = CGPoint(
                            x: self.view.frame.origin.x,
                            y: -self.view.frame.size.height
                        )
                }, completion: { (isCompleted) in
                    if isCompleted {
                        self.dismiss(animated: false, completion: nil)
                    }
                })
            }
            else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.imageView.center = self.originalPosition!
                })
            }
        }
    }
    
    @objc func tapAction() {
        if self.view.backgroundColor == .black {
            UIView.animate(withDuration: 0.2, animations: {
                self.view.backgroundColor = UIColor(white: 1, alpha: 0.3)
                self.labelBackgroundView.isHidden = false
                self.senderLabel.isHidden = false
            })
        }
        else {
            UIView.animate(withDuration: 0.2, animations: {
                self.view.backgroundColor = .black
                self.labelBackgroundView.isHidden = true
                self.senderLabel.isHidden = true
            })
        }
    }
    
    @objc func swipeLeft() {
        UIView.animate(withDuration: 0.4, animations: {
            self.imageView.frame.origin = CGPoint(
                x: -self.view.frame.size.width,
                y: 0
            )
        }) { (isCompleted) in
            self.imageView.frame.origin = CGPoint(
                x: 0,
                y: 0
            )
            self.swipePhoto(left: true)
        }
    }
    
    @objc func swipeRight() {
        UIView.animate(withDuration: 0.4, animations: {
            self.imageView.frame.origin = CGPoint(
                x: self.view.frame.size.width,
                y: 0
            )
        }) { (isCompleted) in
            self.imageView.frame.origin = CGPoint(
                x: 0,
                y: 0
            )
            self.swipePhoto(left: false)
        }
    }
}

extension ChatImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
