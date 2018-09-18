//
//  PastelViewManager.swift
//  Limbo
//
//  Created by A-Team User on 7.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit
import Pastel

class PastelViewManager: NSObject {
    static func addPastelViewToCollectionViewBackground(collectionView: UICollectionView, withSuperView view: UIView) {
        
        let pastelView = PastelView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: collectionView.frame.height))
        pastelView.startPastelPoint = .bottomLeft
        pastelView.endPastelPoint = .topRight
        pastelView.animationDuration = 3.0
        pastelView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pastelView.setColors([
            UIColor(red:0.46, green:0.43, blue:0.60, alpha:1.0),
            UIColor(red:0.37, green:0.33, blue:0.55, alpha:1.0),
            UIColor(red:0.23, green:0.20, blue:0.36, alpha:1.0)
            ])
        
        collectionView.backgroundView = pastelView
        collectionView.backgroundColor = .clear
        
        let gradient = CAGradientLayer()
        let endColor = UIColor(red:0.02, green:0.11, blue:0.16, alpha:0.5)
        
        gradient.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: collectionView.frame.height)
        gradient.colors = [UIColor.clear.cgColor, endColor.cgColor, endColor.cgColor, UIColor.clear.cgColor]
        gradient.locations = [0, 0.1, 0.9, 1]
        pastelView.layer.mask = gradient
        
        pastelView.startAnimation()
    }
    
}
