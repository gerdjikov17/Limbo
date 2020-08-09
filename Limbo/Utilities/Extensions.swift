//
//  Extensions.swift
//  Limbo
//
//  Created by A-Team User on 8.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import Foundation
import UIKit

extension StringProtocol {
    var ascii: [UInt32] {
        return unicodeScalars.compactMap { $0.isASCII ? $0.value : nil }
    }
}

extension Character {
    var ascii: UInt32? {
        return String(self).ascii.first
    }
}

extension Array {
    var random: Element {
        precondition(!isEmpty)
        return self[Int.random(max: count - 1)]
    }
}

extension Int {
    
    static func random(min: Int = 0, max: Int) -> Int {
        precondition(min >= 0 && min <= max)
        return Int(arc4random_uniform(UInt32((max - min) + 1))) + min
    }
    
}


extension String {
    
    func firstLetterCapitalized() -> String {
        guard !isEmpty else { return self }
        return self[startIndex...startIndex].uppercased() + self[index(after: startIndex)..<endIndex]
    }
    
    func shuffle() -> String {
        let shuffledString = self.sorted { (_, _) -> Bool in
            arc4random() < arc4random()
        }
        return String(shuffledString)
    }
    
}

extension CALayer {
    
    func addPulsingAnimation() {
        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.duration = 1
        pulseAnimation.fromValue = 1
        pulseAnimation.toValue = 0.5
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .greatestFiniteMagnitude
        self.add(pulseAnimation, forKey: "opacityAnimation")
    }
    
    func addScaleXAnimation(scaleFactor: Float) {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale.x")
        scaleAnimation.duration = 2
        scaleAnimation.fromValue = 1
        scaleAnimation.toValue = scaleFactor
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        scaleAnimation.autoreverses = true
        scaleAnimation.repeatCount = .greatestFiniteMagnitude
        self.add(scaleAnimation, forKey: "scaleXAnimation")
    }
    
    func addScaleYAnimation(scaleFactor: Float) {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale.y")
        scaleAnimation.duration = 2
        scaleAnimation.fromValue = 1
        scaleAnimation.toValue = scaleFactor
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        scaleAnimation.autoreverses = true
        scaleAnimation.repeatCount = .greatestFiniteMagnitude
        self.add(scaleAnimation, forKey: "scaleYAnimation")
    }

}

extension FileManager {
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}

extension UIImageView {
    func loadAsyncImage(fromURL: URL) {
        if let cachedImage = ImageCache.shared.getImage(forKey: fromURL.absoluteString as NSString) {
            self.image = cachedImage
            return
        }
        else {
            URLSession.shared.dataTask(with: fromURL) { (data, response, error) in
                
                if error != nil {
                    DispatchQueue.main.async {
                        self.image = #imageLiteral(resourceName: "ghost_avatar.png")
                        return
                    }
                    
                }
                
                DispatchQueue.main.async {
                    let image = UIImage(data: data!)
                    ImageCache.shared.cacheImage(image: image!, forKey: NSString(string: fromURL.absoluteString))
                    self.image = image
                }
            }.resume()
        }
    }
    
    func loadAsyncImage(localURL: URL) {
        if let image = ImageCache.shared.getImage(forKey: (localURL.absoluteString as NSString)) {
            DispatchQueue.main.async {
                self.image = image
            }
            print("gets data from the cache")
        }
        else {
            if let imageData = try? Data(contentsOf: localURL) {
                if let image = UIImage(data: imageData) {
                    ImageCache.shared.cacheImage(image: image, forKey: (localURL.absoluteString as NSString))
                    DispatchQueue.main.async {
                        self.image = image
                    }
                }
            }
        }
    }
}
