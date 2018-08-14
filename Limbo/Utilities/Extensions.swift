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
        precondition(min >= 0 && min < max)
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
}
