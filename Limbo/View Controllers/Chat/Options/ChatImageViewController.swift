//
//  ChatImageViewController.swift
//  Limbo
//
//  Created by A-Team User on 20.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit

class ChatImageViewController: UIViewController {

    @IBOutlet weak var labelBackgroundView: UIView!
    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    var image: UIImage!
    var senderUsername: String!
    var panGestureRecognizer: UIPanGestureRecognizer?
    var originalPosition: CGPoint?
    var currentPositionTouched: CGPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(white: 1, alpha: 0.3)
        self.imageView.image = image
        self.senderLabel.text = senderUsername
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        view.addGestureRecognizer(panGestureRecognizer!)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction)))
        self.scrollView.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
}

extension ChatImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
