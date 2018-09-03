//
//  CustomEmptyDataSetDelegate.swift
//  Limbo
//
//  Created by A-Team User on 3.09.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class CustomEmptyDataSetDelegate: NSObject, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    var emptyDataSetTitle: String!
    
    init(emptyDataSetTitle: String) {
        self.emptyDataSetTitle = emptyDataSetTitle
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: emptyDataSetTitle)
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        let image = #imageLiteral(resourceName: "ghost_avatar.png")
        var newWidth: CGFloat
        if UIDevice.current.userInterfaceIdiom == .pad {
            newWidth = 200
        }
        else {
            newWidth = 100
        }
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight), blendMode: .normal, alpha: 0.5)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
